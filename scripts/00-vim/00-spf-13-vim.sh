#!/bin/bash

sudo apt-get install -y vim

cp $(dirname $0)/.vimrc.local ~/
cp $(dirname $0)/.vimrc.before.local  ~/
cp $(dirname $0)/.vimrc.bundles.local  ~/
curl http://j.mp/spf13-vim3 -L -o - | sh

