#!/bin/bash
namespace="default"
vms="freeipa1 freeipa2 freeipa3"

for vm in $vms; do
  echo $vm
  cat <<EOF | kubectl apply -f -
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
done
