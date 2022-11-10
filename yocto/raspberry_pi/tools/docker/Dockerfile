# Dockerfile build:
#   - host:/<Dockerfile path>$ docker build -t ess/crops-extended .
# usage:
#   - $ cd <rpi4 linux dir>
#   - $ docker run -ti -v $PWD:/build ess/crops-extended
# docker run --rm -it -v $PWD:/workdir ess/crops-extended --workdir=/workdir

# docker container run -it --rm -v $PWD:/workdir --workdir=/workdir --name ess-qt2boot --volume $PWD/home:/home/yocto --env DL_DIR=/workdir/cache/downloads --env SSTATE_DIR=/workdir/cache/sstate --env BB_NUMBER_THREADS=10 --env PARALLEL_MAKE=-j10 ess/crops-extended

FROM crops/poky
USER root

RUN apt-get install -y -q repo \
 git-lfs

#USER pokyuser
