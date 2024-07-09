# FreeIPA with Terraform and Ansible

This repository contains sample code from the article available at [Terraform + Ansible で 認証統合基盤 FreeIPA クラスタを構築する - Qiita](https://qiita.com/sawa2d2/items/6fe6432a47b1e8bcd857)

## Steps

Provision VMs:
```
terraform init
terraform apply -auto-approve
```

Install Ansible FreeIPA collection from Ansible Galaxy:
```
ansible-galaxy collection install freeipa.ansible_freeipa
```

Install FreeIPA:
```
ansible-playbook -i hosts.ini $HOME/.ansible/collections/ansible_collections/freeipa/ansible_freeipa/playbooks/install-cluster.yml
```

