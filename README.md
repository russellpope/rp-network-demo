kpsc-prod-ansible
=================

This code is used to manage resources owned by Tower in the KPSC.

Example Ansible-Playbook Run using Docker
----------------------------
```
docker build -t local/ansible .
docker run -ti -v `pwd`:/workingdir local/ansible bash
cd /workingdir
ansible-galaxy install -r roles/requirements.yml -p ./roles/ --force
ansible-playbook -i development --private-key=towen_kpsc --ask-vault-pass netbox.yml
```