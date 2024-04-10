#!/bin/bash
#
# v--- IMPORTANT NOTE ---v
#
# NOTE: Changes here should be copied to:
# https://github.com/Irys-Solutions/vita/blob/main/bin/vita-versions.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/assets/post-gen/vita-versions.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/scripts/build/vita-versions.sh
# Assuming vita and runner-images are checked out in the same parent directory;
# to copy to the runner-images repository, in the vita repository, run:
# make setup-apt-to-runner-images
#
# ^--- IMPORTANT NOTE ---^

node_version="18"
postgres_server_version="15"  # NOTE: vita-ci-cd.yml has to be updated with the same version
python_version="3.12"
python_source_version="${python_version}.3"

export NODE_VERSION="${node_version}"
export POSTGRES_SERVER_VERSION="${postgres_server_version}"
export PYTHON_VERSION="${python_version}"
export PYTHON_SOURCE_VERSION="${python_source_version}"
