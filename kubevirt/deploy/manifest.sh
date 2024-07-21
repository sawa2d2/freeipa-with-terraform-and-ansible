#!/bin/bash

function create_vm()
{
  vm=$1
  node=$2

  preference=centos.stream9
  image=rocky9

  virtctl create vm \
  --name=$vm \
  --instancetype=u1.medium \
  --preference=$preference \
  --volume-clone-pvc=src:kubevirt-os-images/$image \
  --cloud-init-user-data $(cat cloud_init.cfg | base64 -w 0) |
  yq eval ".spec.template.spec.nodeSelector = {\"kubernetes.io/hostname\": \"$node\"}" | \
  yq eval '.spec.template.spec.domain.devices.interfaces += [{"name": "eth0", "bridge": {}}]' | \
  yq eval '.spec.template.spec.networks += [{"name": "eth0", "pod": {}}]'
}


function create_service()
{
  vm=$1
  namespace="default"
  cat <<EOF
apiVersion: v1
kind: Service
metadata:
  name: $vm
  namespace: $namespace
spec:
  ports:
  - name: ssh
    port: 22
    targetPort: 22
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
  - name: http2
    port: 8080
    targetPort: 8080
  - name: tomcat
    port: 8005
    targetPort: 8005
  - name: https2
    port: 8443
    targetPort: 8443
  - name: ldap
    port: 389
    targetPort: 389
  - name: ldaps
    port: 636
    targetPort: 636
  - name: kerberos
    port: 88
    targetPort: 88
  selector:
    vm.kubevirt.io/name: $vm
EOF
}

function create()
{
  for i in 0 1 2; do
    vm=freeipa$((i+1))
    node=master${i}
    filename=vm_${vm}.yaml
    echo Creating $filename
    create_vm "$vm" "$node" > "$filename"
  done
  
  for vm in freeipa1 freeipa2 freeipa3; do
    filename=svc_${vm}.yaml
    echo Creating $filename
    create_service "$vm" > "$filename"
  done
}

function apply()
{
  for i in 0 1 2; do
    vm=freeipa$((i+1))
    node=master${i}
    filename=vm_${vm}.yaml
    oc delete vm -n default $vm

    echo Creating $filename
    create_vm "$vm" "$node" | oc apply -f -
  done
  
  for vm in freeipa1 freeipa2 freeipa3; do
    filename=svc_${vm}.yaml
    echo Creating $filename
    create_service "$vm" | oc apply -f -
  done
}

function usage()
{
  echo "Error: Invalid argument. Only 'create' or 'apply' are allowed."
  echo "Usage: $0 <create|apply>"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

if [ "$1" == "create" ]; then
  create
elif [ "$1" == "apply" ]; then
  apply
else
  usage
fi
