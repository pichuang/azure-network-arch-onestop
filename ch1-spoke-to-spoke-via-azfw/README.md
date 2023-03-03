# Challenge 1: Spoke to Spoke via Azure Firewall

- Goal: Create a hub and spoke topology with two spokes connected via Azure Firewall.

- Susccess Criteria
  1. Should follow the hub and spoke topology.
  2. Use Azure Firewall to allow ICMP traffic from Spoke1 to Spoke2, and deny all other traffic.
  3. Azure Firewall logs should be enabled and sent to Log Analytics, and the logs should be queried to show the traffic.