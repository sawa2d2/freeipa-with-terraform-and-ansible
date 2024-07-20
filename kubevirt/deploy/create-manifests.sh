#!/bin/bash

# Create VirtualMachines
function create_vm()
{
  vm=$1
  node=$2
  filename=vm_${vm}.yaml
  echo Creating $filename

  preference=centos.stream9
  image=rocky9

  virtctl create vm \
  --name=$vmname \
  --instancetype=u1.medium \
  --preference=$preference \
  --volume-clone-pvc=src:kubevirt-os-images/$image \
  --cloud-init-user-data $(cat cloud_init.cfg | base64 -w 0) |
  yq eval ".spec.template.spec.nodeSelector = {\"kubernetes.io/hostname\": \"$node\"}" | \
  yq eval '.spec.template.spec.domain.devices.interfaces += [{"name": "eth0", "bridge": {}}]' | \
  yq eval '.spec.template.spec.networks += [{"name": "eth0", "pod": {}}]' > \
  "$filename"
}

for i in 0 1 2; do

  vm=freeipa$((i+1))
  node=master${i}
  #oc delete vm -n default $vm
  create_vm "$vm" "$node"
done

# Create Services
namespace="default"

function create_service()
{
  filename=svc_${vm}.yaml
  echo Creating $filename
  cat <<EOF > "$filename"
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

for vm in freeipa1 freeipa2 freeipa3; do
  create_service "$vm"
done
