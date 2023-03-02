## Code Name: 1-transit-vnet

## Step

- Apply architecture

``` bash
terraform init
terraform plan
terraform apply -auto-approve
```

- Destory architecture

``` bash
terraform destroy
```

- ETA from noghting to running: 5 minutes

## Arch

- vnet-hub-japaneast (10.73.30.0/24)
  - vm-hub-test
    - nic-hub: 10.73.30.5
  - firewall-japaneast: 10.73.30.4
- vnet-spoke1-japaneast (10.73.31.0/24)
  - vm-spoke1-test
    - nic-spoke1: 10.73.31.4
- vnet-spoke2-japaneast (10.73.33.0/24)
  - vm-spoke2-test
    - nic-spoke2: 10.73.33.4


``` Access Basion
# Access vm-hub VM
az network bastion ssh --name bastion-japaneast --resource-group rg-transit-vnet --target-resource-id $(az vm show -g rg-transit-vnet -n vm-hub --query "id" --output tsv) --auth-type password --username repairman

# Access vm-spoke1 VM
az network bastion ssh --name bastion-japaneast --resource-group rg-transit-vnet --target-resource-id $(az vm show -g rg-transit-vnet -n vm-spoke1 --query "id" --output tsv) --auth-type password --username repairman

# Access vm-spoke2 VM
az network bastion ssh --name bastion-japaneast --resource-group rg-transit-vnet --target-resource-id $(az vm show -g rg-transit-vnet -n vm-spoke2 --query "id" --output tsv) --auth-type password --username repairman
```


``` bash
sudo apt update -y
sudo apt install iputils-ping mtr git vim -y
git clone https://github.com/upa/deadman
```

- deadman.conf
``` bash
nic-spoke1 10.73.31.4
nic-spoke2 10.73.33.4
nic-hub 10.73.30.5
firewall-hub 10.73.30.4
```