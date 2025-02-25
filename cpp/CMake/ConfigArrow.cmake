# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set(ARROW_SHARED_LIBRARY_SUFFIX ".so.1200")
set(ARROW_SHARED_LIBRARY_PARENT_SUFFIX ".so.1200.0.0")

set(ARROW_LIB_NAME "arrow")
set(PARQUET_LIB_NAME "parquet")
set(ARROW_DATASET_LIB_NAME "arrow_dataset")
set(ARROW_SUBSTRAIT_LIB_NAME "arrow_substrait")

function(FIND_ARROW_LIB LIB_NAME)
  if(NOT TARGET Arrow::${LIB_NAME})
    set(ARROW_LIB_FULL_NAME ${CMAKE_SHARED_LIBRARY_PREFIX}${LIB_NAME}${ARROW_SHARED_LIBRARY_SUFFIX})
    add_library(Arrow::${LIB_NAME} SHARED IMPORTED)
    set_target_properties(Arrow::${LIB_NAME}
        PROPERTIES IMPORTED_LOCATION "${root_directory}/releases/${ARROW_LIB_FULL_NAME}"
        INTERFACE_INCLUDE_DIRECTORIES
        "${root_directory}/releases/include")
    find_library(ARROW_LIB_${LIB_NAME}
        NAMES ${ARROW_LIB_FULL_NAME}
        PATHS ${ARROW_LIB_DIR} ${ARROW_LIB64_DIR}
        NO_DEFAULT_PATH)
    if(NOT ARROW_LIB_${LIB_NAME})
        message(FATAL_ERROR "Arrow Library Not Found: ${ARROW_LIB_FULL_NAME}")
    else()
        message(STATUS "Found Arrow Library: ${ARROW_LIB_${LIB_NAME}}")
    endif()
    file(COPY ${ARROW_LIB_${LIB_NAME}} DESTINATION ${root_directory}/releases/ FOLLOW_SYMLINK_CHAIN)
  endif()
endfunction()

message(STATUS "Use existing ARROW libraries")

set(ARROW_INSTALL_DIR "${ARROW_HOME}/arrow_install")
set(ARROW_LIB_DIR "${ARROW_INSTALL_DIR}/lib")
set(ARROW_LIB64_DIR "${ARROW_INSTALL_DIR}/lib64")
set(ARROW_INCLUDE_DIR "${ARROW_INSTALL_DIR}/include")

message(STATUS "Set Arrow Library Directory in ${ARROW_LIB_DIR} or ${ARROW_LIB64_DIR}")
message(STATUS "Set Arrow Include Directory in ${ARROW_INCLUDE_DIR}")

if(EXISTS ${ARROW_INCLUDE_DIR}/arrow)
  set(ARROW_INCLUDE_SRC_DIR ${ARROW_INCLUDE_DIR})
else()
  message(FATAL_ERROR "Arrow headers not found in ${ARROW_INCLUDE_DIR}/arrow.")
endif()

# Copy arrow headers
set(ARROW_INCLUDE_DST_DIR ${root_directory}/releases/include)

string(TOUPPER "${BUILD_BENCHMARKS}" LOWERCASE_BUILD_BENCHMARKS)
set(ARROW_INCLUDE_SUB_DIR arrow parquet)
message(STATUS "Copy Arrow headers from ${ARROW_INCLUDE_SRC_DIR} to ${ARROW_INCLUDE_DST_DIR}")
file(MAKE_DIRECTORY ${ARROW_INCLUDE_DST_DIR})
foreach(SUB_DIR ${ARROW_INCLUDE_SUB_DIR})
  file(COPY ${ARROW_INCLUDE_SRC_DIR}/${SUB_DIR} DESTINATION ${ARROW_INCLUDE_DST_DIR})
endforeach()
