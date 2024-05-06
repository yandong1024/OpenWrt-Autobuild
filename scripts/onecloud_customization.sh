#!/bin/bash

set -ex

cp -rf ../target/linux/amlogic target/linux/

source ./01_customize_packages.sh

exit 0
