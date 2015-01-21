#!/bin/bash


echo "make sudo password less."
sudo sed -i -e '1,$s/^%sudo.*$/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/'  /etc/sudoers

echo "apt-get update"
sudo apt-get update

echo "install ag, tmux"
sudo apt-get install -y silversearcher-ag tmux git mercurial exuberant-ctags dos2unix make  build-essential

git config --global push.default current


# install fasd
wget https://github.com/clvv/fasd/tarball/1.0.1 -O fasd.tar.gz
tar xvf fasd.tar.gz
sudo make install -C clvv-fasd-4822024
rm -rf fasd.tar.gz clvv-fasd-4822024
echo 'eval "$(fasd --init auto)"' >> $HOME/.bashrc
echo "added fasd to ~/.bashrc"
