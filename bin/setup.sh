#!/usr/bin/env bash

# Check we're not root
if [ `whoami` == "root" ]; then
  echo "You can't run this script as root!"
  exit 1
fi

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
  sudo apt-get -y --no-install-recommends install curl wget colordiff htop meld ncftp imagemagick gmic optipng pngquant libimage-exiftool-perl tmux dos2unix cifs-utils offlineimap gparted exfat-fuse exfat-utils

  # Internet
  sudo apt-get -y --no-install-recommends install firefox chromium-browser torbrowser-launcher

  # OpenSSH
  sudo apt-get -y --no-install-recommends install openssh-client openssh-server

  # Multimedia
  sudo apt-get -y --no-install-recommends install mplayer vlc ffmpeg

  # Coding tools
  sudo apt-get -y --no-install-recommends install build-essential clang git mercurial cmake pkg-config valgrind doxygen

  # Dev libraries
  sudo apt-get -y --no-install-recommends install libgl1-mesa-dev mesa-common-dev libjpeg-dev libpng12-dev libtiff5-dev libopenexr-dev libcurl4-openssl-dev libhdf5-dev

  # Python 2
  sudo apt-get -y --no-install-recommends install python python-dev virtualenv python-pip python-virtualenv python-setuptools ipython ipython-notebook

  # Python 3
  sudo apt-get -y --no-install-recommends install python3 python3-dev python3-pip python3-virtualenv python3-setuptools ipython3 ipython3-notebook

  # AWS
  sudo apt-get -y --no-install-recommends install awscli

  # Latex
  sudo apt-get -y --no-install-recommends install texlive-latex-recommended

  # Gimp
  sudo apt-get -y --no-install-recommends install gimp

  # Check if we have a NVIDIA graphics card
  # The command below returns the number of NVIDIA graphics card found
  sudo apt-get -y --no-install-recommends install pciutils
  NVIDIA_DETECTED=`lspci | grep "VGA compatible controller\|3D controller" | grep "NVIDIA\|GeForce" | wc -l`
  if [ ${NVIDIA_DETECTED} == '0' ]; then
    echo -e "\n\n\n--- No NVIDIA graphics card found ---\n\n\n"
  else
    echo -e "\n\n\n--- ${NVIDIA_DETECTED} NVIDIA graphics card(s) found: installing drivers, CUDA and cuDNN ---\n\n\n"
    NVIDIA_VERSION=390
    CUDA_PKG_1=cuda_9.0.176_384.81_linux.run
    CUDA_PKG_2=cuda_9.0.176.1_linux.run
    CUDNN_PKG=cudnn-9.0-linux-x64-v7.3.1.20.tgz
    TMPDIR=$(mktemp -d)
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt-get -y update
    sudo apt-get -y --no-install-recommends install nvidia-${NVIDIA_VERSION} nvidia-settings libcuda1-${NVIDIA_VERSION} nvidia-opencl-icd-${NVIDIA_VERSION}
    if [ -d "/usr/local/cuda" ]; then
      sudo /usr/local/cuda/bin/uninstall_cuda_*.pl --silent
    fi
    sudo rm -rf /usr/local/cuda*
    git clone https://github.com/oliviersoares/nvidia ${TMPDIR}
    cat ${TMPDIR}/${CUDA_PKG_1}* > ${TMPDIR}/${CUDA_PKG_1}
    cat ${TMPDIR}/${CUDA_PKG_2}* > ${TMPDIR}/${CUDA_PKG_2}
    cat ${TMPDIR}/${CUDNN_PKG}*  > ${TMPDIR}/${CUDNN_PKG}
    sudo sh ${TMPDIR}/${CUDA_PKG_1} --silent --toolkit
    sudo sh ${TMPDIR}/${CUDA_PKG_2} --silent --accept-eula
    sudo tar xvzf ${TMPDIR}/${CUDNN_PKG} -C /usr/local
    find /usr/local/cuda/ -exec sudo chown -h root:root {} \;
    rm -rf ${TMPDIR}
    pushd /usr/lib/x86_64-linux-gnu/
    sudo rm -f libGL.so
    sudo ln -s ../nvidia-${NVIDIA_VERSION}/libGL.so
    popd
    nvidia-smi
  fi

  # Clean
  echo -e "\n\n\n--- Cleaning system ---\n\n\n"
  sudo apt-get -y autoremove
  sudo apt-get -y autoclean
  sudo apt-get -y clean
  sudo rm -rf /var/lib/apt/lists/*

elif [ "$(uname)" == "Darwin" ]; then

  # Disable crash dialog window
  defaults write com.apple.CrashReporter DialogType none

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
  brew cask install firefox google-chrome tor-browser

  # Editors
  brew install vim nedit
  brew cask install geany

  # Tools
  brew install coreutils findutils curl wget htop nmap tmux ncftp ffmpeg gnupg offlineimap
  brew cask install iterm2 meld vlc gimp
  brew install imagemagick --with-x11
  brew install gmic optipng pngquant ghostscript exiftool

  # Coding tools
  brew install cmake git mercurial valgrind doxygen

  # Dev libraries
  brew install jpeg libpng libtiff openexr hdf5

  # Python
  brew install python ipython

  # AWS
  brew install awscli

  # Latex
  brew cask install basictex

  # Find pip (Python 2)
  if hash pip2 2>/dev/null; then
    PIP2=pip2
  elif hash pip 2>/dev/null; then
    PIP2=pip
  else
    echo -e "Could not find pip command"
    echo -e "Install it on Debian-based Linux with command: sudo apt-get -y --no-install-recommends install python-pip"
    echo -e "Install it on macOS via HomeBrew with command: brew install python"
    exit 1
  fi

  # Virtualenv (via pip)
  ${PIP2} install --upgrade virtualenv

  # Find pip
  if hash pip3 2>/dev/null; then
    PIP3=pip3
  else
    echo -e "Could not find pip command"
    echo -e "Install it on Debian-based Linux with command: sudo apt-get -y --no-install-recommends install python3-pip"
    echo -e "Install it on macOS via HomeBrew with command: brew install python"
    exit 1
  fi

  # Virtualenv (via pip)
  ${PIP3} install --upgrade virtualenv
fi

echo -e "\n\n\nDone with setup.sh\n\n\n"
