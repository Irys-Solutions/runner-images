#!/bin/bash -xe
#
# v--- IMPORTANT NOTE ---v
#
# NOTE: Changes should be made in the sources of truth here:
# https://github.com/Irys-Solutions/vita/blob/main/bin/vita-versions.sh
# https://github.com/Irys-Solutions/vita/blob/main/bin/setup-apt.sh
#
# After that then they should be copied to here:
# https://github.com/Irys-Solutions/dresden/blob/main/dresden/install/vita-bin-setup-apt.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/assets/post-gen/vita-bin-setup-apt.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/scripts/build/install-vita-bin-setup-apt.sh
#
# To do this copy to the dresden and runner-images repositories,
# assuming vita, dresden, and runner-images are checked out in the same parent directory,
# in the vita repository, run:
#
# make push-setup-apt
#
# ^--- IMPORTANT NOTE ---^

export NODE_VERSION="18"
export POSTGRES_SERVER_VERSION="15" # NOTE: vita-ci-cd.yml has to be updated with the same version
export PYTHON_SOURCE_VERSION="3.12.3"
export PYTHON_VERSION="3.12"
#!/bin/bash -xe
#
# v--- IMPORTANT NOTE ---v
#
# NOTE: Changes should be made in the sources of truth here:
# https://github.com/Irys-Solutions/vita/blob/main/bin/vita-versions.sh
# https://github.com/Irys-Solutions/vita/blob/main/bin/setup-apt.sh
#
# After that then they should be copied to here:
# https://github.com/Irys-Solutions/dresden/blob/main/dresden/install/vita-bin-setup-apt.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/assets/post-gen/vita-bin-setup-apt.sh
# https://github.com/Irys-Solutions/runner-images/blob/main/runner-images/images/ubuntu/scripts/build/install-vita-bin-setup-apt.sh
#
# To do this copy to the dresden and runner-images repositories,
# assuming vita, dresden, and runner-images are checked out in the same parent directory,
# in the vita repository, run:
#
# make push-setup-apt
#
# ^--- IMPORTANT NOTE ---^

[ X"$(uname -s)"X = X"Linux"X ] || exit 0

basedir=$(dirname "$0")

[ -f "${basedir}/vita-versions.sh" ] && source "${basedir}/vita-versions.sh"

# In case we are running as root without sudo installed
( apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install sudo -y ) || true

sudo rm -f \
  /etc/apt/sources.list.d/00-security.debian.org.list \
  /etc/apt/sources.list.d/00-security.ubuntu.com.list \
  /etc/apt/sources.list.d/01-mirror.linux.org.au.list \
  /etc/apt/sources.list.d/01-au.archive.ubuntu.com.list \
  /etc/apt/sources.list.d/pgdg.list \
  /etc/apt/sources.list.d/azure-cli.list \
  /etc/apt/sources.list.d/yarn.list


sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  apt-transport-https \
  curl \
  gpg \
  lsb-release \
  software-properties-common \
  sudo \
  wget \
  -y

lsb_release -cs
if [ X"$(lsb_release -is)"X = X"Debian"X ]; then
  echo "deb http://security.debian.org/debian-security $(lsb_release -cs)-security main contrib non-free" \
    | sudo tee /etc/apt/sources.list.d/00-security.debian.org.list

  (echo "deb http://mirror.linux.org.au/debian $(lsb_release -cs) main contrib non-free" \
   && echo "deb http://mirror.linux.org.au/debian $(lsb_release -cs)-updates main contrib non-free" \
  ) | sudo tee /etc/apt/sources.list.d/01-mirror.linux.org.au.list
 source /etc/os-release
 wget -q https://packages.microsoft.com/config/debian/"$VERSION_ID"/packages-microsoft-prod.deb
elif [ X"$(lsb_release -is)"X = X"Ubuntu"X ]; then
  echo "deb http://security.ubuntu.com/ubuntu $(lsb_release -cs)-security main restricted universe multiverse" \
    | sudo tee /etc/apt/sources.list.d/00-security.ubuntu.com.list
  ( echo "deb http://au.archive.ubuntu.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse" \
    && echo "deb http://au.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse" \
    && echo "deb http://au.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse" \
  ) | sudo tee /etc/apt/sources.list.d/01-au.archive.ubuntu.com.list
  source /etc/os-release
  wget -q https://packages.microsoft.com/config/ubuntu/"$VERSION_ID"/packages-microsoft-prod.deb
else
  echo "Unknown distribution: $(lsb_release -is)"
  exit 1
fi

# Add Packages Microsoft Com (PMC) repository
sudo dpkg -i packages-microsoft-prod.deb
# Delete the Microsoft repository keys file
rm packages-microsoft-prod.deb

sudo add-apt-repository ppa:deadsnakes/ppa -y # Python repository

wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs 2>/dev/null)-pgdg main" \
  | sudo tee /etc/apt/sources.list.d/pgdg.list

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc | sudo apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/azure-cli.list

wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] http://dl.yarnpkg.com/debian/ stable main" \
 | sudo tee /etc/apt/sources.list.d/yarn.list

curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" > "setup_${NODE_VERSION}.x.sh"
[ -f "setup_${NODE_VERSION}.x.sh" ]
bash "setup_${NODE_VERSION}.x.sh"

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
#  Note: includes all the dependencies for Python builds
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  azure-cli \
  build-essential \
  cron \
  curl \
  dialog \
  dnsutils \
  file \
  gettext \
  git \
  git-lfs \
  inetutils-ping \
  inetutils-traceroute \
  jq \
  lbzip2 \
  less \
  libbz2-dev \
  libffi-dev \
  libgdbm-dev \
  libicu70 \
  libncurses5-dev \
  libnss3-dev \
  libpq-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libz-dev \
  locales \
  locales-all \
  lsof \
  moreutils \
  net-tools \
  netcat-traditional \
  nginx-light \
  nodejs \
  pip \
  postgresql-client \
  powershell \
  procps \
  python"$PYTHON_VERSION" \
  python"$PYTHON_VERSION"-venv \
  python3 \
  python3-pip \
  python3-virtualenv \
  redis-tools \
  rsync \
  screen \
  sysfsutils \
  time \
  tmux \
  unzip \
  vim-tiny \
  wait-for-it \
  wget \
  wget2 \
  yarn \
  zip \
  zlib1g-dev \
  -y
sudo apt-get autoremove
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
