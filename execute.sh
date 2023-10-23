#!/bin/shs

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
k apply -f https://raw.githubusercontent.com/cniackz/kes-testing/main/deployment.yaml
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
cd ~
rm configure-vault.sh
wget https://raw.githubusercontent.com/cniackz/kes-testing/main/configure-vault.sh
chmod +x configure-vault.sh
./configure-vault.sh

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
