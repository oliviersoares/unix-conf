#!/usr/bin/env bash

echo -e "\n\n\n--- Starting setup.sh ---\n\n\n"

if [ "$(uname)" == "Linux" ]; then

  # Install sudo if not available (assuming running as root)
  if ! type "sudo" &> /dev/null; then
    apt-get -y --no-install-recommends install sudo
  fi

  # Update system
  echo -e "\n\n\n--- Updating system ---\n\n\n"
  sudo apt-get -y update
  sudo apt-get -y upgrade

  # Remove amazon crap and flash plugin
  sudo apt-get -y remove --purge unity-webapps-common flashplugin-installer

  # Disable Ubuntu apport
  service apport stop
  sed -i -e s/^enabled\=1$/enabled\=0/ /etc/default/apport
  sudo apt-get -y remove --purge apport

  # Set locales
  echo -e "\n\n\n--- Setting locales ---\n\n\n"
  sudo apt-get -y --no-install-recommends install locales
  locale-gen en_US.utf8
  update-locale LANG=en_US.utf8

  # Installing packages
  echo -e "\n\n\n--- Installing packages ---\n\n\n"

  # Text editors
  sudo apt-get -y --no-install-recommends install vim nedit geany

  # Tools
  sudo apt-get -y --no-install-recommends install curl wget colordiff htop meld terminator ncftp  imagemagick optipng pngquant tmux dos2unix

  # Internet
  sudo apt-get -y --no-install-recommends install firefox chromium-browser

  # Multimedia
  sudo apt-get -y --no-install-recommends install mplayer vlc

  # Coding tools
  sudo apt-get -y --no-install-recommends install build-essential clang git mercurial cmake pkg-config valgrind doxygen

  # Dev libraries
  sudo apt-get -y --no-install-recommends install libgl1-mesa-dev mesa-common-dev libopenexr-dev openexr libz-dev libopencv-dev libeigen3-dev libgoogle-glog-dev libceres-dev libimage-exiftool-perl

  # Python
  sudo apt-get -y --no-install-recommends install python python-dev python-pip

  # AWS
  sudo apt-get -y --no-install-recommends install awscli

  # Latex
  sudo apt-get -y --no-install-recommends install texlive-latex-recommended

  # Gimp
  sudo apt-get -y --no-install-recommends install gimp

  # DJView
  TMPDIR=$(mktemp -d)
  DJV_PKG=djv-1.1.0-Linux-64.deb
  wget -P ${TMPDIR} https://downloads.sourceforge.net/project/djv/djv-stable/1.1.0/${DJV_PKG}
  sudo dpkg -i ${TMPDIR}/${DJV_PKG}
  rm -rf ${TMPDIR}

  # Docker
  # See instructions here: https://docs.docker.com/engine/installation/linux/ubuntu
  echo -e "\n\n\n--- Installing docker ---\n\n\n"
  sudo apt-get -y remove --purge docker docker-engine
  sudo rm -rf /var/lib/docker
  sudo apt-get install -y --no-install-recommends apt-transport-https ca-certificates software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-get install software-properties-common lsb-release
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get -y update
  sudo apt-get install -y --no-install-recommends docker-ce
  if [ ! -z $USER ]; then
    sudo groupadd docker
    sudo usermod -aG docker $USER
  fi
  sudo service docker start
  sudo systemctl enable docker

  # Check if we have a NVIDIA graphics card
  # The command below returns the number of NVIDIA graphics card found
  sudo apt-get -y --no-install-recommends install pciutils
  NVIDIA_DETECTED=`lspci | grep "VGA compatible controller\|3D controller" | grep "NVIDIA\|GeForce" | wc -l`
  if [ ${NVIDIA_DETECTED} == '0' ]; then
    echo -e "\n\n\n--- No NVIDIA graphics card found ---\n\n\n"
  else
    echo -e "\n\n\n--- ${NVIDIA_DETECTED} NVIDIA graphics card(s) found: installing drivers, CUDA and cuDNN ---\n\n\n"
    NVIDIA_VERSION=384
    CUDA_PKG=cuda_8.0.61_375.26_linux.run
    CUDNN_PKG=cudnn-8.0-linux-x64-v5.1.tgz
    NVIDIA_DOCKER_PKG=nvidia-docker_1.0.1-1_amd64.deb
    TMPDIR=$(mktemp -d)
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt-get -y update
    sudo apt-get -y --no-install-recommends install nvidia-${NVIDIA_VERSION} nvidia-settings libcuda1-${NVIDIA_VERSION} nvidia-opencl-icd-${NVIDIA_VERSION}
    sudo rm -rf /usr/local/cuda*
    git clone https://github.com/oliviersoares/nvidia ${TMPDIR}
    cat ${TMPDIR}/${CUDA_PKG}*  > ${TMPDIR}/${CUDA_PKG}
    cat ${TMPDIR}/${CUDNN_PKG}* > ${TMPDIR}/${CUDNN_PKG}
    sudo sh ${TMPDIR}/${CUDA_PKG} --silent --toolkit
    sudo tar xvzf ${TMPDIR}/${CUDNN_PKG} -C /usr/local
    wget -P ${TMPDIR} https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/${NVIDIA_DOCKER_PKG}
    sudo dpkg -i ${TMPDIR}/${NVIDIA_DOCKER_PKG}
    rm -rf ${TMPDIR}
    pushd /usr/lib/x86_64-linux-gnu/
    sudo rm -f libGL.so
    sudo ln -s ../nvidia-${NVIDIA_VERSION}/libGL.so
    popd
    nvidia-smi
  fi

  # Find pip
  if hash pip 2>/dev/null; then
    PIP=pip
  elif hash pip2 2>/dev/null; then
    PIP=pip2
  else
    echo "Can't find pip!" 1>&2
    exit 1
  fi

  # Python update
  sudo -H ${PIP} install --upgrade pip
  sudo -H ${PIP} install --upgrade virtualenv
  sudo -H ${PIP} install --upgrade setuptools
  ${PIP} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 sudo -H ${PIP} install --upgrade

  # Clean
  echo -e "\n\n\n--- Cleaning system ---\n\n\n"
  sudo apt-get -y autoremove
  sudo apt-get -y autoclean
  sudo apt-get -y clean
  sudo rm -rf /var/lib/apt/lists/*

elif [ "$(uname)" == "Darwin" ]; then

  # Disable crash dialog window
  defaults write com.apple.CrashReporter DialogType none

  # Change repeat rate
  defaults write -g InitialKeyRepeat -int 10
  defaults write -g KeyRepeat -int 1

  # Disable analytics
  brew analytics off

  # Update system
  echo -e "\n\n\n--- Updating system ---\n\n\n"
  brew update
  brew upgrade

  # Installing packages
  echo -e "\n\n\n--- Installing packages ---\n\n\n"

  # Xquartz (for X11)
  brew cask install xquartz

  # Internet
  brew cask install firefox google-chrome thunderbird torbrowser tunnelblick

  # Editors
  brew install vim nedit
  brew cask install geany

  # Tools
  brew install coreutils findutils curl wget htop nmap tmux ncftp exiftool
  brew cask install iterm2 meld vlc spotify gimp djv meshlab
  brew install imagemagick --with-x11
  brew install optipng pngquant ghostscript

  # Coding tools
  brew install cmake git mercurial valgrind doxygen

  # Dev libraries
  brew install homebrew/science/opencv eigen openexr zlib glog ceres-solver

  # Python
  brew install python

  # AWS
  brew install awscli

  # Latex
  brew cask install basictex

  # Docker
  brew cask install docker

  # Find pip
  if hash pip 2>/dev/null; then
    PIP=pip
  elif hash pip2 2>/dev/null; then
    PIP=pip2
  else
    echo "Can't find pip!" 1>&2
    exit 1
  fi

  # Python update
  ${PIP} install --upgrade pip
  ${PIP} install --upgrade virtualenv
  ${PIP} install --upgrade setuptools
  ${PIP} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 ${PIP} install --upgrade
fi

echo -e "\n\n\nDone with setup.sh\n\n\n"
