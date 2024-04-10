#!/bin/bash -xe
#
# v--- IMPORTANT NOTE ---v
#
# NOTE: Changes should be made in the source of truth here:
# https://github.com/Irys-Solutions/vita/blob/main/bin/vita-versions.sh
#
# After that then they should be copied to here:
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/assets/post-gen/vita-bin-setup-apt.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/scripts/build/install-vita-bin-setup-apt.sh
#
# Assuming vita and runner-images are checked out in the same parent directory;
# to copy to the runner-images repository, in the vita repository, run:
#
# make setup-apt-to-runner-images
#
# ^--- IMPORTANT NOTE ---^

export NODE_VERSION="18"
export OLD_PYTHON_SOURCE_VERSION="3.8.19"
export OLD_PYTHON_VERSION="3.8"
export POSTGRES_SERVER_VERSION="15" # NOTE: vita-ci-cd.yml has to be updated with the same version
export PYTHON_SOURCE_VERSION="3.12.3"
export PYTHON_VERSION="3.12"
#!/bin/bash -xe

# v--- IMPORTANT NOTE ---v
#
# NOTE: Changes should be made in the source of truth here:
# https://github.com/Irys-Solutions/vita/blob/main/bin/vita-versions.sh
#
# After that then they should be copied to here:
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/assets/post-gen/vita-bin-setup-apt.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/scripts/build/install-vita-bin-setup-apt.sh
#
# Assuming vita and runner-images are checked out in the same parent directory;
# to copy to the runner-images repository, in the vita repository, run:
#
# make setup-apt-to-runner-images
#
# ^--- IMPORTANT NOTE ---^
basedir=$(dirname "$0")

[ -f "${basedir}/vita-versions.sh" ] && source "${basedir}/vita-versions.sh"

[ X"$(uname -s)"X = X"Linux"X ] || exit 0

sudo rm -f /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install wget lsb-release -y
lsb_release -cs
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs 2>/dev/null)-pgdg main" \
  | sudo tee /etc/apt/sources.list.d/pgdg.list
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc | sudo apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
# Note: includes all the dependencies for Python
sudo apt-get install \
  azure-cli \
  gettext \
  git \
  git-lfs \
  jq \
  moreutils \
  nodejs \
  build-essential \
  curl \
  libbz2-dev \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libnss3-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  postgresql-client \
  procps \
  python3 \
  python3-pip \
  python3-virtualenv \
  redis-tools \
  time \
  wget \
  yarnpkg \
  zlib1g-dev \
  -y
sudo apt-get autoremove
# KEEP INSTALL OF OLD PYTHON VERSION for now, until we complete migration in OSLO-5150
if which "python${OLD_PYTHON_VERSION}"; then
  echo "Python ${OLD_PYTHON_VERSION} installed already"
else
  echo "Python ${OLD_PYTHON_VERSION} installing from source"
  cd /tmp
  curl -O "https://www.python.org/ftp/python/${OLD_PYTHON_SOURCE_VERSION}/Python-${OLD_PYTHON_SOURCE_VERSION}.tgz"
  tar xzf "Python-${OLD_PYTHON_SOURCE_VERSION}.tgz"
  cd "Python-${OLD_PYTHON_SOURCE_VERSION}"
  ./configure --enable-optimizations
  make -j "$(nproc)"
  sudo make altinstall
  cd
  sudo rm -rf /tmp/Python*
fi
if which "python${PYTHON_VERSION}"; then
  echo "Python ${PYTHON_VERSION} installed already"
else
  echo "Python ${PYTHON_VERSION} installing from source"
  cd /tmp
  curl -O "https://www.python.org/ftp/python/${PYTHON_SOURCE_VERSION}/Python-${PYTHON_SOURCE_VERSION}.tgz"
  tar xzf "Python-${PYTHON_SOURCE_VERSION}.tgz"
  cd "Python-${PYTHON_SOURCE_VERSION}"
  ./configure --enable-optimizations
  make -j "$(nproc)"
  sudo make altinstall
  cd
  sudo rm -rf /tmp/Python*
fi
