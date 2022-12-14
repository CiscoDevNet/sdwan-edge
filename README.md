# Cisco SDWAN edge deployments

Sample implementations of IaC for deploying the Cisco Catalyst 8000v on different platforms:

- [Amazon AWS](Catalyst8000v/aws/)
- [Microsoft Azure](Catalyst8000v/azure/)
- [Google GCP](Catalyst8000v/gcp/)
- [VMWare vSphere](Catalyst8000v/vmware/)
- [Openstack](Catalyst8000v/openstack/)

as well as auto-onboarding into the Cisco SDWAN overlay.
Below is the generic architecture of the minimal deployment.

![C8KV Deployment](cedge_deployment.png)

There are 2 interfaces configured on the c8kv:

- GE1 will be configured as a Tunnel interface and will connect to the SDWAN CP
- GE2 will connect to an internal private network

Additional minimal configuration is also provided: hostname, ntp server, user&password to be created.

The required cloud-init file for the different scripts can be generated using the ansible script in the GenerateCloudInit folder, details [here](GenerateCloudInit/).

The deployment scripts are applying a day0 configuration on the router which is auto-generated with the provided Ansible scripts, making the router work in Controller mode and onboard on the specified SDWAN fabric.

The provided code is based on the premise that the deployment is done on existing infrastructure - in terms of networks/subnets, routing tables, vpc/vnet and so on, and then the IDs of those structures need to be provided as values for the input variables.

However, we also provide sample scripts for creating this infrastructure if it does not exist, so that by mixing those scripts it is easy to create code that performs a greenfield deployment if needed.

Please refer to the specific details of each platform for running the scripts.

Issues: To add your question, create an issue in this repository, create an [Issues](https://github.com/CiscoDevNet/sdwan-edge/issues) here.
