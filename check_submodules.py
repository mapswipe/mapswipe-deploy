import typing
import re
import configparser
import os
import subprocess
from itertools import groupby


class SubmoduleInfo(typing.TypedDict):
    name: str
    path: str
    url: str


class ExtendedSubmoduleInfo(SubmoduleInfo):
    commit: str
    branch: str | None


def read_submodules(filepath=".gitmodules") -> list[SubmoduleInfo]:
    config = configparser.ConfigParser()
    config.read(filepath)

    submodules = []
    for section in config.sections():
        match = re.search(r'submodule\s+"(.+)"', section)
        if not match:
            continue

        submodules.append({
            "name": match.group(1),
            "path": config[section].get("path"),
            "url": config[section].get("url"),
        })
    return submodules


def get_submodules(repo_path: str) -> list[SubmoduleInfo]:
    gitmodules_path = os.path.join(repo_path, ".gitmodules")
    if not os.path.exists(gitmodules_path):
        return []

    return read_submodules(gitmodules_path)


def run_git_command(args: list[str], cwd: str):
    result = subprocess.run(
        ["git"] + args,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"Git command failed in {cwd}: {' '.join(args)}\n{result.stderr}"
        )
    return result.stdout.strip()


def collect_versions(
    repo_path: str,
    *,
    error_summary: str,
    base_path: str,
    seen_paths: set[str],
    submodules_info: list[ExtendedSubmoduleInfo],
) -> tuple[bool, str]:
    repo_path = os.path.abspath(repo_path)

    # Make sure we don't process the same path again.
    if repo_path in seen_paths:
        print(f"🔍 Already scanned: {repo_path}")
        return (False, error_summary)

    seen_paths.add(repo_path)

    # Make sure submodules are initialized
    # subprocess.run(
    #     ["git", "submodule", "init"],
    #     cwd=repo_path,
    #     check=True,
    # )
    # subprocess.run(
    #     ["git", "submodule", "update", "--recursive", "--init"],
    #     cwd=repo_path,
    #     check=True,
    # )

    errored = False
    mutable_error_summary = error_summary

    submodules = get_submodules(repo_path)
    for submodule in submodules:
        sub_path = os.path.join(repo_path, submodule["path"])
        short_path = os.path.relpath(sub_path, start=base_path)

        if submodule["url"].startswith("https"):
            errored = True
            mutable_error_summary += (
                f"⚠️ Submodule is initialized with https: {short_path}" + "\n"
            )
            # continue

        if not os.path.isdir(sub_path):
            message = f"⚠️ Submodule directory not found: {short_path}"
            print(message)
            errored = True
            mutable_error_summary += message + "\n"
            continue

        print(f"🔍 Processing submodule directory: {short_path}")

        commit: str = run_git_command(["rev-parse", "HEAD"], cwd=sub_path)
        branch: str | None = run_git_command(["name-rev", "--name-only", commit], cwd=sub_path)
        print(f"🔖 Commit: {commit}")
        print(f"🔀 Branch: {branch or 'n/a'}")

        submodules_info.append({
            **submodule,
            "path": short_path,
            "commit": commit,
            "branch": branch,
        })

        # Recurse into this submodule
        sub_errored, sub_summary = collect_versions(
            sub_path,
            base_path=base_path,
            seen_paths=seen_paths,
            error_summary=mutable_error_summary,
            submodules_info=submodules_info,
        )

        errored = errored or sub_errored
        mutable_error_summary = sub_summary

    return (errored, mutable_error_summary)


def main():
    summary_file = os.getenv("GITHUB_STEP_SUMMARY")
    base_repo = os.getcwd()
    seen_paths = set[str]()
    submodules_info = list[ExtendedSubmoduleInfo]()

    base_str = "<h2>Submodules Analysis</h2>\n"

    errored, summary = collect_versions(
        base_repo,
        base_path=base_repo,
        seen_paths=seen_paths,
        error_summary="",
        submodules_info=submodules_info,
    )

    if errored:
        base_str += "<p>Encountered errors while reading submodules information.</h3>\n"
        base_str += "<pre><code>\n"
        base_str += summary
        base_str += "</code></pre>\n"

    sorted_submodules_info = sorted(submodules_info, key=lambda x: x["url"])
    grouped_submodules_info = [
        (key, list(iter))
        for key, iter in groupby(sorted_submodules_info, key=lambda info: info["url"])
    ]

    errored_groups = [
        (key, lst)
        for (key, lst) in grouped_submodules_info
        if len(lst) > 1 and any(item["commit"] != lst[0]["commit"] for item in lst)
    ]

    if len(errored_groups) > 1:
        base_str += (
            "<p>"
            "Same repository should use the same commit to ensure correcteness during deployment."
            f"There are {len(errored_groups)} repositories that do not meet this criteria."
            "</p>\n"
            "<table>\n"
            "<tr>"
            "<th>Repository</th>"
            "<th>Path</th>"
            "<th>Commit</th>"
            "<th>Branch</th>"
            "</tr>\n"
        )
        for key, lst in errored_groups:
            for item in lst:
                base_str += (
                    "<tr>"
                    f"<td>{key}</th>"
                    f"<td>{item['path']}</th>"
                    f"<td>{item['commit']}</th>"
                    f"<td>{item['branch']}</th>"
                    "</tr>\n"
                )
        base_str += "</table>\n"
    else:
        base_str += "There are no issues!"

    if summary_file:
        with open(summary_file, "a") as f:
            f.write(base_str)
    else:
        print(base_str)

    if errored or len(errored_groups) > 1:
        exit(1)


if __name__ == "__main__":
    main()
