#!/usr/bin/env bash

set -eu
set -x

BUILD_CPP=${1:-ON}
BUILD_TESTS=${2:-OFF}
BUILD_ARROW=${3:-ON}
STATIC_ARROW=${4:-OFF}
BUILD_PROTOBUF=${5:-ON}
BUILD_FOLLY=${6:-ON}
ARROW_ROOT=${7:-/usr/local}
ARROW_BFS_INSTALL_DIR=${8}
BUILD_JEMALLOC=${9:-ON}
BUILD_GAZELLE_CPP_BACKEND=${10:-OFF}
BUILD_VELOX_BACKEND=${11:-OFF}
VELOX_HOME=${12}
BUILD_TYPE=${13:-release}
BUILD_BENCHMARKS=${14:-OFF}
BACKEND_TYPE=${15:-velox}
ENABLE_HBM=${16:-OFF}
VELOX_ENABLE_S3=${17:-OFF}
VELOX_ENABLE_HDFS=${18:-OFF}

if [ "$BUILD_CPP" == "ON" ]; then
  NPROC=$(nproc --ignore=2)

  CURRENT_DIR=$(
    cd "$(dirname "$BASH_SOURCE")"
    pwd
  )
  cd "${CURRENT_DIR}"

  if [ -d build ]; then
    rm -r build
  fi
  mkdir build
  cd build
  cmake .. \
    -DBUILD_TESTS=${BUILD_TESTS} \
    -DBUILD_ARROW=${BUILD_ARROW} \
    -DSTATIC_ARROW=${STATIC_ARROW} \
    -DBUILD_PROTOBUF=${BUILD_PROTOBUF} \
    -DBUILD_FOLLY=${BUILD_FOLLY} \
    -DARROW_ROOT=${ARROW_ROOT} \
    -DARROW_BFS_INSTALL_DIR=${ARROW_BFS_INSTALL_DIR} \
    -DBUILD_JEMALLOC=${BUILD_JEMALLOC} \
    -DBUILD_GAZELLE_CPP_BACKEND=${BUILD_GAZELLE_CPP_BACKEND} \
    -DBUILD_VELOX_BACKEND=${BUILD_VELOX_BACKEND} \
    -DVELOX_HOME=$(if [ $VELOX_HOME == "\"\"" ]; then echo "${CURRENT_DIR}/../ep/build-velox/build/velox_ep"; else echo $VELOX_HOME; fi) \
    -DCMAKE_BUILD_TYPE=$(if [ "$BUILD_TYPE" == "debug" ] || [ "$BUILD_TYPE" == "Debug" ]; then echo 'Debug';\
                         elif [ "$BUILD_TYPE" == "release" ] || [ "$BUILD_TYPE" == "Release" ]; then echo 'Release';\
                         elif [ "$BUILD_TYPE" == 'relWithDebInfo' ] || [ "$BUILD_TYPE" == "RelWithDebInfo" ]; then echo 'RelWithDebInfo'; fi) \
    -DDEBUG=$(if [ "$BUILD_TYPE" == "debug" ]; then echo 'ON'; else echo 'OFF'; fi) \
    -DBUILD_BENCHMARKS=${BUILD_BENCHMARKS} \
    -DBACKEND_TYPE=${BACKEND_TYPE} \
    -DENABLE_HBM=${ENABLE_HBM} \
    -DVELOX_ENABLE_S3=${VELOX_ENABLE_S3} \
    -DVELOX_ENABLE_HDFS=${VELOX_ENABLE_HDFS}
  make -j$NPROC
fi
