# Solution 1: Spoke-to-Spoke via Azure Firewall

## Show Solution

``` bash
# For new challenger
terraform init
terraform plan
terraform apply -auto-approve
```

- Destory Solution 1

``` bash
terraform destroy -auto-approve
```

## You May Need to known

### IP Address

- vnet-hub (10.73.30.0/24)
  - vm-hub-test
    - nic-hub: 10.73.30.164
  - firewall: 10.73.30.4
- vnet-spoke1 (10.73.31.0/24)
  - vm-spoke1-test
    - nic-spoke1: 10.73.31.4
- vnet-spoke2 (10.73.33.0/24)
  - vm-spoke2-test
    - nic-spoke2: 10.73.33.4

### Username / Password

- repairman / Lyc0r!sRec0il

### Access VMs via Azure Basion

``` bash
# Access vm-hub VM
az network bastion ssh --name bastion --resource-group rg-challenge-01 --target-resource-id $(az vm show -g rg-challenge-01 -n vm-hub --query "id" --output tsv) --auth-type password --username repairman

# Access vm-spoke1 VM
az network bastion ssh --name bastion --resource-group rg-challenge-01 --target-resource-id $(az vm show -g rg-challenge-01 -n vm-spoke1 --query "id" --output tsv) --auth-type password --username repairman

# Access vm-spoke2 VM
az network bastion ssh --name bastion --resource-group rg-challenge-01 --target-resource-id $(az vm show -g rg-challenge-01 -n vm-spoke2 --query "id" --output tsv) --auth-type password --username repairman
```

### Check Public IP

``` bash
curl ifconfig.me/all
```

## Misc

```
# For debug only
TF_LOG="DEBUG" terraform apply -auto-approve
```