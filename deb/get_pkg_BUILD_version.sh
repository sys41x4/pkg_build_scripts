#!/bin/sh

pkg_BUILD_dir=$1

echo ${pkg_BUILD_dir}/*.changes | rev | cut -d'_' -f 2 | rev
