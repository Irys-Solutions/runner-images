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
export POSTGRES_SERVER_VERSION="15" # NOTE: vita-global-variables.yml should be updated with this
export PYTHON_SOURCE_VERSION="3.12.6"  # https://www.python.org/ftp/python/
export PYTHON_VERSION="3.12"  # NOTE: vita-global-variables.yml and dresden-ci-cd.yml should be updated with this
export OTHER_PYTHON_SOURCE_VERSION="3.12.6"  # https://www.python.org/ftp/python/
export OTHER_PYTHON_VERSION="3.12"  # NOTE: If we are rotating python version, put the old one here for a while
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


sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gpg \
  lsb-release \
  software-properties-common \
  sudo \
  wget \
  -y

if ! [ -f /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh ] ; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get remove postgresql-client postgresql-client-common -y || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install postgresql-common -y
fi

lsb_release -cs
if [ X"$(lsb_release -is)"X = X"Debian"X ]; then
  echo "deb http://security.debian.org/debian-security $(lsb_release -cs)-security main contrib non-free" \
    | sudo tee /etc/apt/sources.list.d/00-security.debian.org.list

  (echo "deb http://mirror.linux.org.au/debian $(lsb_release -cs) main contrib non-free" \
   && echo "deb http://mirror.linux.org.au/debian $(lsb_release -cs)-updates main contrib non-free" \
  ) | sudo tee /etc/apt/sources.list.d/01-mirror.linux.org.au.list
elif [ X"$(lsb_release -is)"X = X"Ubuntu"X ]; then
  if grep security.ubuntu.com /etc/apt/sources.list ; then
    true
  elif grep security.ubuntu.com /etc/apt/sources.list.d/* ; then
    true
  else
    echo "deb http://security.ubuntu.com/ubuntu $(lsb_release -cs)-security main restricted universe multiverse" \
      | sudo tee /etc/apt/sources.list.d/00-security.ubuntu.com.list
  fi
#  ( echo "deb http://au.archive.ubuntu.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse" \
#    && echo "deb http://au.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse" \
#    && echo "deb http://au.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse" \
#  ) | sudo tee /etc/apt/sources.list.d/01-au.archive.ubuntu.com.list
  if [ X"$(dpkg --print-architecture)"X = X"arm64"X ]; then
    find /etc/apt -type f -name '*.list' -exec sed -i.bak "sX//[^/]*ubuntu.com/ubuntu X//ports.ubuntu.com/ubuntu-ports X" {} \;
  fi
else
  echo "Unknown distribution: $(lsb_release -is)"
  exit 1
fi

sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/azure-cli.list

wget -qO - https://dl.yarnpkg.com/debian/pubkey.gpg \
  | sudo tee /etc/apt/trusted.gpg.d/yarn-archive-keyring.asc
echo "deb http://dl.yarnpkg.com/debian/ stable main" \
 | sudo tee /etc/apt/sources.list.d/yarn.list

curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" > "setup_${NODE_VERSION}.x.sh"
[ -f "setup_${NODE_VERSION}.x.sh" ]
sudo bash "setup_${NODE_VERSION}.x.sh"

find /etc/apt -type f -name '*.list' -print0 | xargs -0 more

sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -i -v "$POSTGRES_SERVER_VERSION" -y
#  Note: includes all the dependencies for Python builds
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  azure-cli \
  build-essential \
  cron \
  curl \
  dialog \
  dnsutils \
  expect \
  file \
  gettext \
  git \
  git-lfs \
  git-restore-mtime \
  inetutils-ping \
  inetutils-traceroute \
  jq \
  lbzip2 \
  less \
  libbz2-dev \
  libffi-dev \
  libgdbm-dev \
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
  nginx \
  nodejs \
  pip \
  procps \
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
  zip \
  zlib1g-dev \
  -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  libicu70 \
  -y || true # This is gone in latest debian and Ubuntu
if which yarn; then
  echo "Yarn installed already"
else
  echo "Yarn installing from yarnpkg.com"
  sudo DEBIAN_FRONTEND=noninteractive apt-get remove yarnpkg -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install yarn -y
fi

if which "python${OTHER_PYTHON_VERSION}"; then
  echo "Python ${OTHER_PYTHON_VERSION} installed already"
elif sudo add-apt-repository ppa:deadsnakes/ppa -y; then
  sudo apt-get update
  #  Note: includes all the dependencies for Python builds
  sudo DEBIAN_FRONTEND=noninteractive apt-get install \
    python"$OTHER_PYTHON_VERSION" \
    python"$OTHER_PYTHON_VERSION"-dev \
    python"$OTHER_PYTHON_VERSION"-venv \
    -y
else
  echo "Python ${OTHER_PYTHON_VERSION} installing from source"
  cd /tmp
  curl -O "https://www.python.org/ftp/python/${OTHER_PYTHON_SOURCE_VERSION}/Python-${OTHER_PYTHON_SOURCE_VERSION}.tgz"
  tar xzf "Python-${OTHER_PYTHON_SOURCE_VERSION}.tgz"
  cd "Python-${OTHER_PYTHON_SOURCE_VERSION}"
  ./configure --enable-optimizations
  make -j "$(nproc)"
  sudo make altinstall
  cd
  sudo rm -rf /tmp/Python*
fi

if which "python${PYTHON_VERSION}"; then
  echo "Python ${PYTHON_VERSION} installed already"
elif sudo add-apt-repository ppa:deadsnakes/ppa -y; then
  sudo apt-get update
  #  Note: includes all the dependencies for Python builds
  sudo DEBIAN_FRONTEND=noninteractive apt-get install \
    python"$PYTHON_VERSION" \
    python"$PYTHON_VERSION"-dev \
    python"$PYTHON_VERSION"-venv \
    -y
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
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  python3 \
  python3-pip \
  python3-virtualenv \
  -y
