#!/bin/bash


echo "make sudo password less."
sudo sed -i -e '1,$s/^%sudo.*$/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/'  /etc/sudoers

echo "apt-get update"
sudo apt-get update

echo "install ag, tmux"
sudo apt-get install -y silversearcher-ag tmux git mercurial exuberant-ctags dos2unix
