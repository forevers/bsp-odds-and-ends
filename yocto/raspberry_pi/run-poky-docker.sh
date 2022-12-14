#!/usr/bin/env bash

set -e

# downloads and sstate cache location outside of project directory
# TODO: consider passing these locations in CL parameters with this as default location
dirs_to_check=( "./cache/downloads" "./cache/sstate" "./home" )
for d in "${dirs_to_check[@]}"; do
  if [[ ! -d ${d} ]]; then
    echo "\"${d}\" directory not found"
    usage
  fi
done

# start interactive docker image
# current directory mounted as /workdir
# docker image managed persistent sdirectory /home/yocto created for bash history
docker container run \
    -it \
    --rm \
    -v "${PWD}":/workdir \
    -v ~:/home/pokyuser \
    --workdir=/workdir \
    --name yocto-ess \
    --volume "${PWD}/home":/home/yocto \
    --env DL_DIR=/workdir/cache/downloads \
    --env SSTATE_DIR=/workdir/cache/sstate \
    --env BB_NUMBER_THREADS=10 \
    --env PARALLEL_MAKE="-j 10" \
    crops/poky
