#!/usr/bin/env bash

# Check we're not root
if [ `whoami` == "root" ]; then
  echo "You can't run this script as root!"
  exit 1
fi

echo -e "\n\n\n--- Starting setup_py.sh ---\n\n\n"
echo -e "\n\n\nInstalling python environment\n\n\n"

# Upgrade pip
pip3 install --upgrade pip
hash -d pip3

# Create virtual environment
if ! hash virtualenv 2>/dev/null; then
  pip3 install --upgrade virtualenv
fi
rm -rf ~/.venv/python3/vpy
mkdir -p ~/.venv/python3/vpy
virtualenv --system-site-packages -p python3 ~/.venv/python3/vpy
. ~/.venv/python3/vpy/bin/activate

# Install packages
pip install --upgrade pip
hash -d pip
pip install --upgrade wheel
pip install --upgrade setuptools
pip install --upgrade future
pip install --upgrade Cython
pip install --upgrade pylint
pip install --upgrade six
pip install --upgrade numpy
pip install --upgrade scipy
pip install --upgrade pandas
pip install --upgrade tables
pip install --upgrade dlib
pip install --upgrade Pillow
pip install --upgrade OpenEXR
pip install --upgrade matplotlib
pip install --upgrade opencv-python
pip install --upgrade boto3
pip install --upgrade h5py
pip install --upgrade protobuf
pip install --upgrade sklearn
pip install --upgrade librosa
pip install --upgrade imgaug
echo -e "\n\n\n--- Installing TensorFlow ---\n\n\n"
if [ -d "/usr/local/cuda" ]; then
  pip install --upgrade tensorflow-gpu==2.2
else
  pip install --upgrade tensorflow==2.2
fi
echo -e "\n\n\n--- Installing CoreML ---\n\n\n"
pip install --upgrade coremltools
echo -e "\n\n\n--- Installing PyTorch ---\n\n\n"
pip install --upgrade torchvision

# Finish
deactivate
echo -e "\n\n\nDone with setup_py.sh\n\n\n"
