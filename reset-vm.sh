#!/bin/bash

image=rocky9
preference=centos.stream9

for i in 0 1 2; do
  vm=freeipa$((i+1))
  node=master${i}
  oc delete vm -n default $vm

  virtctl create vm \
  --name=$vm \
  --instancetype=u1.medium \
  --preference=$preference \
  --volume-clone-pvc=src:kubevirt-os-images/$image \
  --cloud-init-user-data $(cat cloud_init.cfg | base64 -w 0) |
  yq eval ".spec.template.spec.nodeSelector = {\"kubernetes.io/hostname\": \"$node\"}" | \
  yq eval '.spec.template.spec.domain.devices.interfaces += [{"name": "eth0", "bridge": {}}]' | \
  yq eval '.spec.template.spec.networks += [{"name": "eth0", "pod": {}}]' | \
  oc apply -f -
done
#  yq eval '.spec.template.spec.domain.devices.interfaces += [{"name": "eth0", "masquerade": {}}]' | \
#  yq eval '.spec.template.spec.networks += [{"name": "eth0", "pod": {}}]' | \
