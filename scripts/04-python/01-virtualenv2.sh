#!/bin/bash


curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.11.6.tar.gz
tar xvfz virtualenv-1.11.6.tar.gz
cd virtualenv-1.11.6
sudo python setup.py install
cd ..
sudo rm -rf virtualenv-1.11.6*



# install virtual env under $HOME/virtual2/
cd $HOME
virtualenv virtual2
