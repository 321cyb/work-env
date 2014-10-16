#!/bin/bash


echo "depend on"
echo "    04-python/01-virtualenv2.sh"
echo "    02-nginx/01-nginx.sh"


source $HOME/virtual2/bin/activate
pip install Django
pip install httplib2
pip install ipython
