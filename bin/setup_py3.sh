#!/usr/bin/env bash

# Check we're not root
if [ `whoami` == "root" ]; then
  echo "You can't run this script as root!"
  exit 1
fi

echo -e "\n\n\n--- Starting setup_py.sh ---\n\n\n"
echo -e "\n\n\nInstalling python environment\n\n\n"

# Create virtual environment
pip3 install --upgrade pip
pip3 install --upgrade virtualenv
rm -rf ~/.venv/python3/tf
mkdir -p ~/.venv/python3/tf
virtualenv --system-site-packages -p python3 ~/.venv/python3/tf
. ~/.venv/python3/tf/bin/activate

# Install packages
pip install --upgrade pip
pip install --upgrade setuptools
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
if [ -d "/usr/local/cuda" ]; then
  echo -e "\n\n\n--- Installing TensorFlow GPU ---\n\n\n"
  pip install --upgrade tensorflow-gpu
else
  echo -e "\n\n\n--- Installing TensorFlow CPU ---\n\n\n"
  pip install --upgrade tensorflow
fi
echo -e "\n\n\n--- Installing Keras ---\n\n\n"
pip install --upgrade keras
echo -e "\n\n\n--- Installing CoreML ---\n\n\n"
pip install --upgrade coremltools

# Finish
deactivate
echo -e "\n\n\nDone with setup_py.sh\n\n\n"
