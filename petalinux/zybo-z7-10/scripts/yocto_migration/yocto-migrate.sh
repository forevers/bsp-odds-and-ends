#!/bin/bash

##
##* © Copyright (C) 2016-2020 Xilinx, Inc
##*
##* Licensed under the Apache License, Version 2.0 (the "License"). You may
##* not use this file except in compliance with the License. A copy of the
##* License is located at
##*
##*     http://www.apache.org/licenses/LICENSE-2.0
##*
##* Unless required by applicable law or agreed to in writing, software
##* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
##* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
##* License for the specific language governing permissions and limitations
##* under the License.
##*/

#**************************************************************
function create_runfile() {
	local tarfile="${1}"
	local runfile="${2}"

cat > ${runfile} <<EOF
#!/bin/bash

CLEANUP_FILES=""
trap do_cleanup INT TERM ABRT KILL HUP QUIT SEGV EXIT

function add_file_cleanup ()
{
        CLEANUP_FILES="\${CLEANUP_FILES} \$*"
}

function do_cleanup ()
{
        if [ -n "\${CLEANUP_FILES}" ]; then
                rm -rf \${CLEANUP_FILES} > /dev/null 2>&1
        fi
}

[ -z \${1} ] && echo "Specify the Yocto SDK directory path: \${0} <YOCTO SDK>" && exit 255
YOCTO_SDK=\$(readlink -f \${1})
RUNFILE=\$(readlink -f \${0})
if [ ! -d "\${YOCTO_SDK}/sources" ] || [ ! -f "\${YOCTO_SDK}/setupsdk" ]; then
	echo "Specified Yocto SDK was not proper/correpted"
	exit 255
fi

SKIP=\$(awk '/^##__PLNX_SDK__/ { print NR + 1; exit 0; }' "\${RUNFILE}")
tail -n +\$SKIP "\${RUNFILE}" > /tmp/yocto-migrate
add_file_cleanup /tmp/yocto-migrate

tar -xzf /tmp/yocto-migrate -C "\${YOCTO_SDK}/sources/" || exit 255

sed -i "s|@@PROOT@@|\${YOCTO_SDK}/sources/petalinux|g" "\${YOCTO_SDK}/sources/petalinux/plnxtool.conf"

result=\$(grep "PLNX_SETUP" "\${YOCTO_SDK}/setupsdk")
if [ -z "\$result" ]; then
	echo -en '\nif [ -n "\$PLNX_SETUP" ]; then \
        \n\t\$ROOT/sources/petalinux/plnx-setupsdk \
        \n\texport PETALINUX=\$ROOT/sources/petalinux \
        \n\texport BB_ENV_EXTRAWHITE="\$BB_ENV_EXTRAWHITE PETALINUX" \
	\nfi' >> "\${YOCTO_SDK}/setupsdk"
fi

exit 0
##__PLNX_SDK__
EOF

cat ${tarfile} >> ${runfile}
chmod a+x ${runfile}
}

function create_setupfile() {
	local dir=${1}
	cat > ${dir}/plnx-setupsdk << EOF
rsync -a \$ROOT/sources/petalinux/plnxtool.conf conf/
if [ -d \$ROOT/sources/petalinux/machine ]; then
	rsync -a \$ROOT/sources/petalinux/machine conf/
fi

result=\$(grep -x "include conf/plnxtool.conf" "conf/local.conf")
[ -z "\$result" ] && echo "include conf/plnxtool.conf" >> conf/local.conf

result=\$(grep -x "include conf/petalinuxbsp.conf" "conf/local.conf")
[ -z "\$result" ] && echo "include conf/petalinuxbsp.conf" >> conf/local.conf

bitbake-layers add-layer \$ROOT/sources/petalinux/project-spec/meta-user

EOF
chmod a+x ${dir}/plnx-setupsdk
}

function create_dir() {
	local dir=${1}
	[ ! -d ${dir} ] && mkdir -p ${dir}
}

function add_file_cleanup ()
{
	CLEANUP_FILES="${CLEANUP_FILES} $*"
}

function do_cleanup ()
{
	if [ -n "${CLEANUP_FILES}" ]; then
		rm -rf ${CLEANUP_FILES} > /dev/null 2>&1
	fi
}

CLEANUP_FILES=""
trap do_cleanup INT TERM ABRT KILL HUP QUIT SEGV EXIT

[ -z ${1} ] && echo "Specify the Petalinux project path: Ex: ${0} <plnx-proj>" && exit 255
PROOT=$(readlink -f ${1})

if [ ! -d ${PROOT}/.petalinux ] || [ ! -f ${PROOT}/config.project ]; then
	echo "Specified Petalinux project path not proper/correpted"
	exit 255
fi

[ -z ${PETALINUX} ] && echo "Source the petalinux tool to exicute the script" && exit 255

OUTDIR_SUFFIX="petalinux"
SCRIPT_DIR=$(dirname $(readlink -f ${0}))
PLNX_DATA="${SCRIPT_DIR}/${OUTDIR_SUFFIX}"

##Create directory structure
create_dir ${PLNX_DATA}
create_dir ${PLNX_DATA}/project-spec
create_dir ${PLNX_DATA}/project-spec/hw-description

add_file_cleanup ${PLNX_DATA}

##Copy plnx data
rsync -a ${PROOT}/build/conf/plnxtool.conf ${PLNX_DATA}/
if [ -d ${PROOT}/build/conf/machine ]; then
	rsync -a ${PROOT}/build/conf/machine ${PLNX_DATA}/
fi
rsync -a `find ${PROOT}/project-spec/hw-description/ \( -name "*.pdi" -o -name "*.bit" -o -name "*.xsa" \)` ${PLNX_DATA}/project-spec/hw-description/
rsync -a ${PROOT}/project-spec/meta-user ${PLNX_DATA}/project-spec/
rsync -a ${PROOT}/project-spec/configs ${PLNX_DATA}/project-spec/
rsync -a ${PETALINUX}/etc/hsm ${PLNX_DATA}/etc/

##Updating plnxtool.conf
sed -i  -e '/TMPDIR/d' \
	-e '/XILINX_SDK_TOOLCHAIN/d' \
	-e '/UNINATIVE_URL/d' \
	-e '/USE_XSCT_TARBALL/d' \
	-e '/XSCTH_WS_pn-device-tree/d' \
	-e "s|${PROOT}|@@PROOT@@|g" ${PLNX_DATA}/plnxtool.conf

create_setupfile "${PLNX_DATA}"

## Create tar file
tar -czf "${SCRIPT_DIR}/${OUTDIR_SUFFIX}.tar.gz" -C ${SCRIPT_DIR}/ ${OUTDIR_SUFFIX}/
add_file_cleanup "${SCRIPT_DIR}/${OUTDIR_SUFFIX}.tar.gz"

create_runfile "${SCRIPT_DIR}/${OUTDIR_SUFFIX}.tar.gz" "${SCRIPT_DIR}/plnx-yocto-migrate.run"
