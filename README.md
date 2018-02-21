work-env
========

setup my work environment, only supports Ubuntu.

Before running, make sure user yabo exists, and ssh is properly setup. Then modify hosts and common.yml for your need, then just run: 
    ansible-playbook  common.yml -k --ask-become-pass -vvv
