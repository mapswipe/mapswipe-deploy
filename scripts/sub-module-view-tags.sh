#!/bin/bash -x

git submodule foreach 'git describe --exact-match --tags'
