echo "apiVersion: v1
kind: Secret
metadata:
  name: kes-tenant-user-0
  namespace: default
  uid: 08f62e3e-3ac1-4199-af46-9ee7a0cc4e15
  resourceVersion: '1083'
  creationTimestamp: '2022-11-29T14:29:22Z'
  labels:
    v1.min.io/tenant: kes-tenant
  managedFields:
    - manager: console
      operation: Update
      apiVersion: v1
      time: '2022-11-29T14:29:22Z'
      fieldsType: FieldsV1
      fieldsV1:
        f:data:
          .: {}
          f:CONSOLE_ACCESS_KEY: {}
          f:CONSOLE_SECRET_KEY: {}
        f:immutable: {}
        f:metadata:
          f:labels:
            .: {}
            f:v1.min.io/tenant: {}
        f:type: {}
  selfLink: /api/v1/namespaces/default/secrets/kes-tenant-user-0
immutable: true
type: Opaque
data:
  CONSOLE_ACCESS_KEY: Y29uc29sZQ==
  CONSOLE_SECRET_KEY: Y29uc29sZTEyMw==" > kes-console.yaml
kubectl apply -f kes-console.yaml
