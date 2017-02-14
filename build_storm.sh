#!/bin/bash
set -x
name=storm
version=${1:-"0.10.0"}
description="Storm is a distributed realtime computation system. Similar to how Hadoop provides a set of general primitives for doing batch processing, Storm provides a set of general primitives for doing realtime computation. Storm is simple, can be used with any programming language, is used by many companies, and is a lot of fun to use!"
url="http://storm-project.net"
arch="all"
section="misc"
package_version="-1"
src_package="apache-storm-${version}.tar.gz"
download_url="https://github.com/downloads/nathanmarz/storm/${src_package}"
download_url="http://apache.rediris.es/storm/apache-storm-${version}/${src_package}"
origdir=$(python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $0/..)
storm_root_dir=/opt/storm

#_ MAIN _#
# Cleanup old debian files
rm -rf ${name}*.deb
# If temp directory exists, remove if
if [ -d tmp ]; then
  rm -rf tmp
fi
# Download code if not exists
if [[ ! -f "${src_package}" ]]; then
  curl -L -s -o ${src_package} ${download_url}
fi
# Make build directory, save location
mkdir -p tmp && pushd tmp
# Create build structure for package
mkdir -p storm
cd storm
mkdir -p build${storm_root_dir}
mkdir -p build/etc/default
mkdir -p build/etc/init
mkdir -p build/var/log/storm

# Explode downloaded archive & cleanup files
tar xfvz ${origdir}/${src_package}
mv apache-storm-${version}/* build${storm_root_dir}

# Copy default files into build structure
cd build
cp ${origdir}/storm ${origdir}/storm-nimbus ${origdir}/storm-supervisor ${origdir}/storm-ui ${origdir}/storm-drpc etc/default
cp ${origdir}/storm-nimbus.conf ${origdir}/storm-supervisor.conf ${origdir}/storm-ui.conf ${origdir}/storm-drpc.conf etc/init
#_ Symlinks for upstart init scripts
#for f in etc/init/*; do f=$(basename $f); f=${f%.conf}; ln -s /lib/init/upstart-job etc/init.d/$f; done

#_ MAKE DEBIAN _#
cd build
fpm -t deb \
    -n $name \
    -v ${version}${package_version} \
    --description "$description" \
    --before-install ${origdir}/pre-install.sh \
    --after-install ${origdir}/post-install.sh \
    --after-remove ${origdir}/post-uninstall.sh \
    --url="${url}" \
    -a ${arch} \
    --prefix=/ \
    -s dir \
    -- .
mv ${name}*.deb ${origdir}/..
popd
