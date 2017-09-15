#!/usr/bin/env bash

# Find pip
if hash pip 2>/dev/null; then
  PIP=pip
elif hash pip2 2>/dev/null; then
  PIP=pip2
else
  echo "Can't find pip!" 1>&2
  exit 1
fi

echo -e "\n\n\n--- Starting setup_py.sh ---\n\n\n"

echo -e "\n\n\nInstalling python environment\n\n\n"
mkdir ~/.venv
rm -rf ~/.venv/tf
virtualenv -p /usr/bin/python2.7 ~/.venv/tf
. ~/.venv/tf/bin/activate
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
${PIP} install --upgrade git+https://github.com/aleju/imgaug
if [ -d "/usr/local/cuda" ]; then
  echo -e "\n\n\n--- Installing TensorFlow GPU ---\n\n\n"
  ${PIP} install --upgrade tensorflow-gpu
else
  echo -e "\n\n\n--- Installing TensorFlow CPU ---\n\n\n"
  ${PIP} install --upgrade tensorflow
fi
echo -e "\n\n\n--- Installing Keras ---\n\n\n"
${PIP} install --upgrade keras
${PIP} freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 ${PIP} install --upgrade
deactivate

echo -e "\n\n\nDone with setup_py.sh\n\n\n"
