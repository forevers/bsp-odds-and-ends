#!/bin/bash

VERSION_HEADER=./project-spec/meta-user/recipes-modules/build-version/files/version.h
rm -f $VERSION_HEADER
echo -e "#pragma once\n#define VERSION \\" >> $VERSION_HEADER

build_version=$(cat build-version.txt)
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
git_version=$(git rev-parse --short HEAD)$(git diff --quiet || echo '+dirty')
printf '"%s-%s+%s\\n"' "$build_version" "$branch" "$git_version" >> $VERSION_HEADER
echo -e "" >> $VERSION_HEADER
