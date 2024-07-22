#!/bin/bash

function create_vm()
{
  vm=$1
  node=$2
  cloud_init=$3

  preference=centos.stream9
  image=rocky9


  virtctl create vm \
  --name=$vm \
  --instancetype=u1.medium \
  --preference=$preference \
  --volume-clone-pvc=src:kubevirt-os-images/$image \
  --cloud-init-user-data "$cloud_init" | \
  yq eval ".spec.template.spec.nodeSelector = {\"kubernetes.io/hostname\": \"$node\"}" | \
  yq eval ".spec.labels = {\"app\": \"freeipa\"}" | \
  yq eval '.spec.template.spec.domain.devices.interfaces += [{"name": "eth0", "bridge": {}}]' | \
  yq eval '.spec.template.spec.networks += [{"name": "eth0", "pod": {}}]'
}

function usage()
{
  echo "Usage: $0 <apply | yaml>"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

if [[ "$1" != "apply" && "$1" != "yaml" ]]; then
  echo "Error: Invalid argument. Only 'apply' or 'yaml' are allowed."
  usage
fi

for i in 0 1 2; do
  vm=freeipa$((i+1))
  node=master${i}
  filename=vm-${vm}.yaml

  if [ "$1" == "apply" ]; then
    oc delete vm -n default $vm
    echo Creating $filename
    cloud_init=$(cat cloud_init.cfg | base64 -w 0)
    create_vm "$vm" "$node" "$cloud_init"| oc apply -f -
  elif [ "$1" == "yaml" ]; then
    cloud_init=$(base64 <<EOF
#cloud-config
users:
  - name: root
    ssh-authorized-keys:
      - <SSH_KEY>
EOF
)
    echo Generated: $filename
    create_vm "$vm" "$node" "$cloud_init" > "$filename"
  else
    usage
  fi

done
