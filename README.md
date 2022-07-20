# Cisco SDWAN edge deployments



Sample implementations of IaC for deploying the Cisco Catalyst 8000v on different platforms:
- [Amazon AWS](Catalyst8000v/aws/README.md)
- [Microsoft Azure](Catalyst8000v/azure/README.md)
- [Google GCP](Catalyst8000v/gcp/README.md)
- [VMWare vSphere](Catalyst8000v/vmware/README.md)
- [Openstack](Catalyst8000v/openstack/README.md)

as well as auto-onboarding into the Cisco SDWAN overlay. 
Below the generic architercture of the minimal deployment.

![C8KV Deployment](cedge_deployment.png)

There are 2 interfaces configured on the c8kv:
- GE1 will be configured as a Tunnel interface and will connect to the SDWAN CP
- GE2 will connect to an internal private network

Additional minimal configuration is also provided: hostname, ntp server, user&password to be created.

The required cloud-init file for the different scripts can be generated using the ansible script in the GenerateCloudInit folder, details [here](../GenerateCloudInit/README.md).

The deployment scripts are aplying a day0 configuration on the router which is auto-generated with the provided Ansible scripts, making the router to work in Controller mode and to onboard on the specified SDWAN fabric.

The provided code is based on the premise that the deployment is done on an existing infrastructure - in terms of networks/subnets, routing tables, vpc/vnet and so on, and the the IDs of those structures need to be provided as values for the input variables.

However, we also provide sample scripts for creating this infrastructure if it does not exist, so that by mixing those scripts it is easy to create code that performs a greenfield deployment if needed.

Please refer to the specific details of each platform on running the scripts.
