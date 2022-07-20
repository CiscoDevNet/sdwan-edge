# Catalyst 8000v deployment on Azure

Deployment of the C8000v on Azure with basic onfiguration and onboarding in the SD-WAN Control Plane.

![C8KV Deployment](c8000v_deployment_azure.png)

## Overview

The scripts will deploy and onboard a Catalyst 8000V in an existing Azure VNET. Following items will be created:

- C8000v instance with a transport interface and a service interface. Basic configuration to connect to an existing SD-WAN Fabric.
- Security groups for the 2 different subnets/interfaces
- Public IP address for the C8000 transport interface

In case needed, the scripts in the vpc folder can be used to create the needed VNET and subnets:
- Transit VNET with a CIDR block
- Transport subnet - used to connect to SD-WAN controllers
- Service subnet - used to connect to application VNETs

Depending on the requirements, the 2 set of scripts can also be combined to create the vpc and deploy the c8kv on one run.


## Terraform - Authenticating to Azure

Terraform supports a number of different methods for authenticating to Azure:
- [Using the Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
- [Using Managed Service Identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity)
- [Using a Service Principal and a Client Certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_certificate)
- [Using a Service Principal and a Client Secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)

### Using Azure CLI

Login to Azure
`$ az login`

To list all C8000v images:
`az vm image list --all -l westeurope  -p cisco -f cisco-c8000v -o table`

You have to accept the legal terms on this subscription before being able to deploy:
`$ az vm image terms accept --urn cisco:cisco-c8000v:17_07_01a-byol:latest`


### Using a Service Principal and a Client Secret

Refer to the link above to create your Application. You can use the Azure CLI or Azure portal.

As you've obtained the credentials for this Service Principal, it's possible to configure them in a few different ways.
For example when storing the credentials as Environment Variables, for example:
```
export TF_VAR_ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export TF_VAR_ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export TF_VAR_ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export TF_VAR_ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

## Create c8000v in a specific VNET

The VNET where it will be deployed as well the 2 needed subnets are expected to already exist.

Deploy Cisco SD-WAN C8000v in the VNET:
- Go to cedge directory
- Edit variables.auto.tfvars.json with appropriate settings.

The complete list of input variables:
- name: common prefix for resource names
- region: Azure region
- rg: resource group name
- virtual_network: and exisitng vnet name (If created with the provided scripts, take the value from the vnet scripts output)
- subnet_transport: name of the subnet to be used for the transport interface (If created with the provided scripts, take the value from the vnet scripts output)
- subnet_service: name of the subnet to be used for the service interface   (If created with the provided scripts, take the value from the vnet scripts output)
- image_id: C8000v instance sku (eg "17_07_01a-byol")
- instance_type: type of AWS instance to be deployed (eg. "Standard_DS1_v2")
- account_username: user to be created (privilege 15). The azure tf provider requires to create an additional admin username along with specifying the cloud-init file. However this can also be included as part of the cloud-init file. While it may be ommited from the cloud-init file, it cannot be omited here
- account_password: password of the user to be created


Terraform deployment.
```
$ terraform init
$ terraform plan
$ terraform apply
```


## Create VNET

Deploy Azure VNET for Cisco SD-WAN C8000v: 
- Go to vnet directory
- Edit variables.auto.tfvars.json with your VNET Name, region, Resource Group Name, subnet-name and VNET cidr_block.

The complete list of input variables:
- name: name of the vnet
- region: Azure region
- rg: name of the vnet resource group
- subnet_name_prefix: prefix to be used on naming the subnets (<subnet_name_prefix>-transport and <subnet_name_prefix>-service)
- address_space:   vnet address space
- subnet_transport_prefix: CIDR prefix of the transport subnet
- subnet_service_prefix: CIDR prefix of the service subnet

With vnet as your current working directory, run terraform.
```
$ terraform init
$ terraform plan
$ terraform apply
```
The vnet name and the subnet names will be displayed at the end of running the scripts. 


## Termination

To terminate c8000v instances, go to the cedge directory and run:
```
$ terraform destroy --auto-approve
```

To destroy the empty VNET, go to the vnet directory and run:
```
$ terraform destroy --auto-approve
```

