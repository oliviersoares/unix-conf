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
  sudo apt-get -y --no-install-recommends install curl wget colordiff htop meld ncftp imagemagick optipng pngquant libimage-exiftool-perl tmux dos2unix

  # Internet
  sudo apt-get -y --no-install-recommends install firefox chromium-browser

  # Multimedia
  sudo apt-get -y --no-install-recommends install mplayer vlc ffmpeg

  # Coding tools
  sudo apt-get -y --no-install-recommends install build-essential clang git mercurial cmake pkg-config valgrind doxygen

  # Dev libraries
  sudo apt-get -y --no-install-recommends install libgl1-mesa-dev mesa-common-dev libjpeg-dev libpng12-dev libtiff5-dev libopenexr-dev

  # Python 2
  sudo apt-get -y --no-install-recommends install python python-dev python-pip

  # Python 3
  sudo apt-get -y --no-install-recommends install python3 python3-dev python3-pip

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
    NVIDIA_VERSION=387
    CUDA_PKG=cuda_8.0.61_375.26_linux.run
    CUDNN_PKG=cudnn-8.0-linux-x64-v6.0.tgz
    TMPDIR=$(mktemp -d)
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt-get -y update
    sudo apt-get -y --no-install-recommends install nvidia-${NVIDIA_VERSION} nvidia-settings libcuda1-${NVIDIA_VERSION} nvidia-opencl-icd-${NVIDIA_VERSION}
    if [ -d "/usr/local/cuda" ]; then
      sudo /usr/local/cuda/bin/uninstall_cuda_*.pl
    fi
    sudo rm -rf /usr/local/cuda*
    git clone https://github.com/oliviersoares/nvidia ${TMPDIR}
    cat ${TMPDIR}/${CUDA_PKG}*  > ${TMPDIR}/${CUDA_PKG}
    cat ${TMPDIR}/${CUDNN_PKG}* > ${TMPDIR}/${CUDNN_PKG}
    sudo sh ${TMPDIR}/${CUDA_PKG} --silent --toolkit
    sudo tar xvzf ${TMPDIR}/${CUDNN_PKG} -C /usr/local
    find /usr/local/cuda/ -exec sudo chown -h root:root {} \;
    rm -rf ${TMPDIR}
    pushd /usr/lib/x86_64-linux-gnu/
    sudo rm -f libGL.so
    sudo ln -s ../nvidia-${NVIDIA_VERSION}/libGL.so
    popd
    nvidia-smi
  fi

  # Find pip (Python 2)
  if hash pip2 2>/dev/null; then
    PIP2=pip2
  elif hash pip 2>/dev/null; then
    PIP2=pip
  else
    echo "Can't find pip for Python 2!" 1>&2
    exit 1
  fi

  # Python 2 update (via pip)
  sudo -H ${PIP2} install --upgrade pip
  sudo -H ${PIP2} install --upgrade virtualenv
  sudo -H ${PIP2} install --upgrade setuptools
  ${PIP2} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 sudo -H ${PIP2} install --upgrade

  # Find pip (Python 3)
  if hash pip3 2>/dev/null; then
    PIP3=pip3
  else
    echo "Can't find pip for Python 3!" 1>&2
    exit 1
  fi

  # Python 3 update (via pip)
  sudo -H ${PIP3} install --upgrade pip
  sudo -H ${PIP3} install --upgrade virtualenv
  sudo -H ${PIP3} install --upgrade setuptools
  ${PIP3} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 sudo -H ${PIP3} install --upgrade

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
  brew cask install firefox torbrowser

  # Editors
  brew install vim nedit
  brew cask install geany

  # Tools
  brew install coreutils findutils curl wget htop nmap tmux ncftp ffmpeg
  brew cask install iterm2 meld vlc spotify gimp
  brew install imagemagick --with-x11
  brew install optipng pngquant ghostscript exiftool

  # Coding tools
  brew install cmake git mercurial valgrind doxygen

  # Dev libraries
  brew install jpeg libpng libtiff openexr

  # Python
  brew install python

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
    echo "Can't find pip for Python 2!" 1>&2
    exit 1
  fi

  # Python 2 update (via pip)
  ${PIP2} install --upgrade pip
  ${PIP2} install --upgrade virtualenv
  ${PIP2} install --upgrade setuptools
  ${PIP2} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 ${PIP2} install --upgrade

  # Find pip (Python 3)
  if hash pip3 2>/dev/null; then
    PIP3=pip3
  else
    echo "Can't find pip for Python 3!" 1>&2
    exit 1
  fi

  # Python 3 update (via pip)
  ${PIP3} install --upgrade pip
  ${PIP3} install --upgrade virtualenv
  ${PIP3} install --upgrade setuptools
  ${PIP3} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 ${PIP3} install --upgrade
fi

echo -e "\n\n\nDone with setup.sh\n\n\n"
