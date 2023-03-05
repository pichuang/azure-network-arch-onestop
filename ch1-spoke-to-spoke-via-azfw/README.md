# Challenge 1: Spoke to Spoke via Azure Firewall

- Goal: Create a hub and spoke topology with two spokes connected via Azure Firewall.

- Susccess Criteria
  1. Make sure you access VMs though Azure Bastion
  2. Make sure all VMs cannot use Default outbound access IP
  3. Make sure all VMs can ping each other include Azure Firewall
  4. Make sure all VMs can update and install Ubuntu packages, and deny access to other sites
  5. Make sure all VMs can download source from pypi, github, and deny access to other sites
  6. Azure Firewall logs should be enabled and sent to Log Analytics, and the logs should be queried to show the traffic.

## How to validate?

For Success Criteria 1 ~ 5, Please access to VMs through Azure Bastion, and run the following command to validate the success criteria.

``` bash
pytest -p no:cacheprovider -v test-challenge1.py
```

and all tests should pass.

- All pass
![](./images/test-ch1-allpass.gif)


For Success Criteria 6, Please access to Azure Portal, and check the following items.

![](./images/firewall-vaildation.png)
