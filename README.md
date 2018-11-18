work-env
========

Setup my work environment, only supports Ubuntu.

Before running, make sure 

    1. user yabo exists or change ansible.cfg file's remote_user to match.
    2. ssh is properly setup if it's not local machine.
    3. Then modify hosts file for your need, leave only the first line and modify IP address. OR leave only the second line if running on local machine.
    4. Then modify common.yml file to remove unneeded parts.

Finally run the following for remote computer:
```
    ansible-playbook common.yml -k --ask-become-pass -vvv
```
or if on local machine:
```
    ansible-playbook common.yml --ask-become-pass -vvv
```
