work-env
========

Setup my work environment, only supports Ubuntu.

Run on local machine
======

Before running, make sure 

1. user yabo exists or change ansible.cfg file's remote_user to match.
2. Then modify hosts file,  leave only the second line with local connection.
3. Then modify common.yml file to remove unneeded parts.

Finally run:
```
    ansible-playbook common.yml --ask-become-pass -vvv
```

Run on remote machine
======

Before running, make sure 

1. user yabo exists or change ansible.cfg file's remote_user to match.
2. ssh is properly setup.
3. Then modify hosts file, leave only the first line and modify IP address.
4. Then modify common.yml file to remove unneeded parts.

Finally run:
```
    ansible-playbook common.yml -k --ask-become-pass -vvv
```
