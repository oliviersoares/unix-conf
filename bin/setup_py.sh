#!/usr/bin/env bash

# Check we're not root
if [ `whoami` == "root" ]; then
  echo "You can't run this script as root!"
  exit 1
fi

echo -e "\n\n\n--- Starting setup_py.sh ---\n\n\n"
echo -e "\n\n\nInstalling python environment\n\n\n"

# Check we have python
if hash /usr/bin/python3 2>/dev/null; then
  PYTHON=/usr/bin/python3
elif hash python3 2>/dev/null; then
  PYTHON=python3
else
  echo -e "Could not find python command"
  echo -e "Install it on Debian-based Linux with command: sudo apt-get -y --no-install-recommends install python3"
  echo -e "Install it on macOS via HomeBrew with command: brew install python"
  exit 1
fi

# Check we have pip
if hash /usr/bin/pip3 2>/dev/null; then
  PIP=/usr/bin/pip3
elif hash pip3 2>/dev/null; then
  PIP=pip3
else
  echo -e "Could not find pip command"
  echo -e "Install it on Debian-based Linux with command: sudo apt-get -y --no-install-recommends install python3-pip"
  echo -e "Install it on macOS via HomeBrew with command: brew install python"
  exit 1
fi

# Upgrade pip
${PIP} install --upgrade pip
hash -d ${PIP}

# Create virtual environment
if ! hash virtualenv 2>/dev/null; then
  ${PIP} install --upgrade virtualenv
fi
rm -rf ~/.venv/python3/vpy
mkdir -p ~/.venv/python3/vpy
virtualenv --system-site-packages -p ${PYTHON} ~/.venv/python3/vpy
. ~/.venv/python3/vpy/bin/activate

# Install packages
${PIP} install --upgrade pip
hash -d ${PIP}
${PIP} install --upgrade wheel
${PIP} install --upgrade setuptools
${PIP} install --upgrade future
${PIP} install --upgrade Cython
${PIP} install --upgrade pylint
${PIP} install --upgrade six
${PIP} install --upgrade numpy
${PIP} install --upgrade scipy
${PIP} install --upgrade pandas
${PIP} install --upgrade tables
${PIP} install --upgrade dlib
${PIP} install --upgrade Pillow
${PIP} install --upgrade OpenEXR
${PIP} install --upgrade matplotlib
${PIP} install --upgrade opencv-python
${PIP} install --upgrade boto3
${PIP} install --upgrade h5py
${PIP} install --upgrade protobuf
${PIP} install --upgrade sklearn
${PIP} install --upgrade librosa
${PIP} install --upgrade imgaug
echo -e "\n\n\n--- Installing TensorFlow ---\n\n\n"
if [ -d "/usr/local/cuda" ]; then
  ${PIP} install --upgrade tensorflow-gpu
else
  ${PIP} install --upgrade tensorflow
fi
echo -e "\n\n\n--- Installing CoreML ---\n\n\n"
${PIP} install --upgrade coremltools
echo -e "\n\n\n--- Installing PyTorch ---\n\n\n"
${PIP} install --upgrade torchvision

# Finish
deactivate
echo -e "\n\n\nDone with setup_py.sh\n\n\n"
