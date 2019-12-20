#!/bin/bash

err_print() {
  echo "Error on line $1"
}
trap 'err_print $LINENO' ERR
set -e


cd `dirname $0`
TESTWAV=test.wav
set -xv

# Build executables
if [ ! -f .done-local-install ]; then
  rm -rf build local-install
  mkdir build
  mkdir local-install
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=../local-install -DCMAKE_BUILD_TYPE=Debug -DJANUS_PLUGINS_DEBUG=1 ..
  make -j8
  make install
  cd -
  touch .done-local-install
fi

# Encode a sample WAV with extra cargo
./local-install/bin/janus-tx \
  --verbose 1 \
  --pset-file ./local-install/share/janus/etc/parameter_sets.csv \
  --pset-id 1 \
  --stream-driver 'wav' --stream-driver-args $TESTWAV --stream-fs 48000 \
  --packet-cargo "Hello World"

# Decode the sample WAV, which should contain the extra cargo
./local-install/bin/janus-rx \
  --verbose 1 \
  --pset-file ./local-install/share/janus/etc/parameter_sets.csv \
  --pset-id 1 \
  --stream-driver 'wav' --stream-driver-args $TESTWAV --stream-fs 48000
