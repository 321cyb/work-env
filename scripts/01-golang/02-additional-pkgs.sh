#!/bin/bash

echo "depends on:"
echo "      01-golang/01-gc.sh"

/usr/local/go/bin/go get github.com/hecticjeff/httpserver
/usr/local/go/bin/go get -u github.com/monochromegane/the_platinum_searcher/...

#This is taken from https://github.com/fatih/vim-go/blob/master/plugin/go.vim
/usr/local/go/bin/go get github.com/nsf/gocode
/usr/local/go/bin/go get golang.org/x/tools/cmd/goimports
/usr/local/go/bin/go get code.google.com/p/rog-go/exp/cmd/godef
/usr/local/go/bin/go get golang.org/x/tools/cmd/oracle
/usr/local/go/bin/go get golang.org/x/tools/cmd/gorename
/usr/local/go/bin/go get github.com/golang/lint/golint
/usr/local/go/bin/go get github.com/kisielk/errcheck
/usr/local/go/bin/go get github.com/jstemmer/gotags
