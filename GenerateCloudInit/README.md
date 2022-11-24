# Generation of cloud init file for Catalyst 8000v

Based on the input information and info retrieved from the specified vmanage, the tool will build a basic cloud-init file (ciscosdwan_cloud_init.<HOSTNAME>.cfg) to be used in any deployments.

## Usage

Fill the necessary variables in the input_vars.yml file and then launch

ansible-playbook ./generate-cloud-init.yml

In order to retrieve the bootstrap config from vManage for a specific device, the *UUID* of the device needs to be specified. As alternative, if the *UUID* is not specified, the *model* needs to be specified and it will select an available device from the existing list in vManage.

The templates may be modified to suit any specific needs. In case the bootstrap from vmanage is multipart - it means the device has a template attached - then the boostrap will be the entire config. If no template is attached the day0.j2 template will be used.
