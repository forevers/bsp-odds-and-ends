#!/bin/bash

VERSION_HEADER_FILE=./project-spec/meta-user/recipes-modules/version/files/version.h
rm -f $VERSION_HEADER_FILE
echo -e "#pragma once\n#define VERSION \\" >> $VERSION_HEADER_FILE

branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
git_version=$(git rev-parse --short HEAD)$(git diff --quiet || echo '+dirty')
printf '"%s+%s\\n"' "$branch" "$git_version" >> $VERSION_HEADER_FILE
