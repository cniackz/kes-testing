#!/bin/sh

# To load the needed functions
source ~/bash-config/common.sh

echo " "
echo " "
echo " "
echo "################################################"
echo " "
echo "Have a cluster with Operator and Vault installed"
echo " "
echo "################################################"
createcluster nodeport
installoperator nodeport
kubectl apply -f https://raw.githubusercontent.com/cniackz/kes-testing/main/deployment.yaml
kubectl wait --namespace default \
	--for=condition=ready pod \
	--selector=app=vault \
	--timeout=120s

















































echo " "
echo " "
echo " "
echo "################"
echo " "
echo "Configure Vault:"
echo " "
echo "################"
sleep 2
# hvs.llM5QYQF9Cg10SowEudvf2j5 <--- VAULT_ROOT_TOKEN example
VAULT_ROOT_TOKEN=$(kubectl logs -l app=vault | grep "Root Token: " | sed -e "s/Root Token: //g")
echo "VAULT_ROOT_TOKEN: ${VAULT_ROOT_TOKEN}"

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
echo "ROLE_ID: ${ROLE_ID}"

# Expected: 0f4289bd-6fb0-4271-483f-0c7d0d1cce44
SECRET_ID=$(kubectl exec $(kubectl get pods -l app=vault  | grep -v NAME | awk '{print $1}') -- sh -c 'VAULT_TOKEN='$VAULT_ROOT_TOKEN' VAULT_ADDR="http://127.0.0.1:8200" vault write -f auth/approle/role/kes-role/secret-id' | grep "secret_id             " | sed -e "s/secret_id             //g")
echo "SECRET_ID: ${SECRET_ID}"

















































echo " "
echo " "
echo " "
echo "#######################"
echo " "
echo "Apply KES Configuration"
echo " "
echo "#######################"
sleep 2
cd ~
rm valid-config.sh
wget https://raw.githubusercontent.com/cniackz/kes-testing/main/valid-config.sh
chmod +x valid-config.sh
./valid-config.sh

echo " "
echo " "
echo " "
echo "######################################"
echo " "
echo "Create Environment Variables for MinIO"
echo " "
echo "######################################"
sleep 2
cd ~
rm env-var.sh
wget https://raw.githubusercontent.com/cniackz/kes-testing/main/env-var.sh
chmod +x env-var.sh
./env-var.sh

echo " "
echo " "
echo " "
echo "###################"
echo " "
echo "Create Console User"
echo " "
echo "###################"
sleep 2
cd ~
rm user.sh
wget https://raw.githubusercontent.com/cniackz/kes-testing/main/user.sh
chmod +x user.sh
./user.sh

echo " "
echo " "
echo " "
echo "############"
echo " "
echo "Apply Tenant"
echo " "
echo "############"
sleep 2
cd ~
rm tenant.sh
wget https://raw.githubusercontent.com/cniackz/kes-testing/main/tenant.sh
chmod +x tenant.sh
./tenant.sh
