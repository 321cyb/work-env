#!/bin/bash

echo "depends on:"
echo "      01-golang/01-gc.sh"

/usr/local/bin/go get github.com/hecticjeff/httpserver
/usr/local/bin/go get -u github.com/monochromegane/the_platinum_searcher/...

#This is taken from https://github.com/fatih/vim-go/blob/master/plugin/go.vim
go get https://github.com/nsf/gocode.git
go get code.google.com/p/rog-go/exp/cmd/godef
go get https://github.com/bradfitz/goimports.git
go get code.google.com/p/go.tools/cmd/oracle
go get code.google.com/p/go.tools/cmd/gorename
go get github.com/golang/lint/golint
go get github.com/kisielk/errcheck
go get github.com/jstemmer/gotags
