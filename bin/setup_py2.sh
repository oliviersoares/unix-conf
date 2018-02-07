#!/usr/bin/env bash

# Check we're not root
if [ `whoami` == "root" ]; then
  echo "You can't run this script as root!"
  exit 1
fi

# Find python
if [ -f /usr/bin/python2 ]; then
  PYTHON=/usr/bin/python2
elif [ -f /usr/bin/python ]; then
  PYTHON=/usr/bin/python
elif hash python2 2>/dev/null; then
  PYTHON=python2
elif hash python 2>/dev/null; then
  PYTHON=python
else
  echo -e "Could not find python command"
  echo -e "Install it on Debian-based Linux with command: sudo apt-get -y --no-install-recommends install python"
  echo -e "Install it on macOS via HomeBrew with command: brew install python"
  exit 1
fi

echo -e "\n\n\n--- Starting setup_py.sh ---\n\n\n"
echo -e "\n\n\nInstalling python environment\n\n\n"

# Create virtual environment
rm -rf ~/.venv/python2/tf
mkdir ~/.venv/python2/tf
virtualenv -p ${PYTHON} ~/.venv/python2/tf
. ~/.venv/python2/tf/bin/activate

# Find pip
if hash pip2 2>/dev/null; then
  PIP=pip2
elif hash pip 2>/dev/null; then
  PIP=pip
else
  echo -e "Could not find pip command"
  echo -e "Install it on Debian-based Linux with command: sudo apt-get -y --no-install-recommends install python-pip"
  echo -e "Install it on macOS via HomeBrew with command: brew install python"
  exit 1
fi

# Install packages
${PIP} install --upgrade six
${PIP} install --upgrade numpy
${PIP} install --upgrade scipy
${PIP} install --upgrade Pillow
${PIP} install --upgrade OpenEXR
${PIP} install --upgrade matplotlib
${PIP} install --upgrade opencv-python
${PIP} install --upgrade boto3
${PIP} install --upgrade h5py
${PIP} install --upgrade protobuf
${PIP} install --upgrade sklearn
${PIP} install --upgrade imgaug
if [ -d "/usr/local/cuda" ]; then
  echo -e "\n\n\n--- Installing TensorFlow GPU ---\n\n\n"
  ${PIP} install --upgrade tensorflow-gpu
else
  echo -e "\n\n\n--- Installing TensorFlow CPU ---\n\n\n"
  ${PIP} install --upgrade tensorflow
fi
echo -e "\n\n\n--- Installing Keras ---\n\n\n"
${PIP} install --upgrade keras
${PIP} install git+https://www.github.com/keras-team/keras-contrib.git
echo -e "\n\n\n--- Installing CoreML ---\n\n\n"
${PIP} install --upgrade coremltools

# Upgrade packages
${PIP} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 ${PIP} install --upgrade

# Finish
deactivate
echo -e "\n\n\nDone with setup_py.sh\n\n\n"
