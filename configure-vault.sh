# hvs.llM5QYQF9Cg10SowEudvf2j5 <--- VAULT_ROOT_TOKEN example
VAULT_ROOT_TOKEN=$(kubectl logs -l app=vault | grep "Root Token: " | sed -e "s/Root Token: //g")

# Expected: Success! Enabled approle auth method at: approle/
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault auth enable approle'

# Expected: Success! Enabled the kv secrets engine at: kv/
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault secrets enable kv'

kubectl cp ~/operator/examples/vault/kes-policy.hcl $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}'):/kes-policy.hcl

# Expected: Success! Uploaded policy: kes-policy
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault policy write kes-policy /kes-policy.hcl'

# Success! Data written to: auth/approle/role/kes-role
kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault write auth/approle/role/kes-role token_num_uses=0 secret_id_num_uses=0 period=5m policies=kes-policy'

# Expected: 003ea2c3-983d-e283-1f93-0c6baa2a710e
ROLE_ID=$(kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault read auth/approle/role/kes-role/role-id' | grep "role_id    " | sed -e "s/role_id    //g")

# Expected: 0f4289bd-6fb0-4271-483f-0c7d0d1cce44
SECRET_ID=$(kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault write -f auth/approle/role/kes-role/secret-id' | grep "secret_id             " | sed -e "s/secret_id             //g")
