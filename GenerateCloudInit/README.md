# Generation of cloud init file for Catalyst 8000v

Based on the input information and info retrieved from the specified vmanage, the tool will build a basic cloud-init file (ciscosdwan_cloud_init.<HOSTNAME>.cfg) to be used in any deployments.

## Usage

Fill the necessary variables in the input_vars.yml file and then launch

    ansible-playbook ./generate-cloud-init.yml

In order to retrieve the bootstrap config from vManage for a specific device, the *UUID* of the device needs to be specified. As alternative, if the *UUID* is not specified, the *model* needs to be specified and it will select an available device from the existing list in vManage.

The templates may be modified to suit any specific needs. In case the bootstrap from vmanage is multipart - it means the device has a template attached - then the boostrap will be the entire config. If no template is attached the day0.j2 template will be used.

### Running the playbook with Pipenv

You don't have to install ansible and dependencies into your openrating system's main file system, you can create and use a Python environment instead, with the **Pipenv** tool:

    pipenv install

You can then drop into the virtual environment's shell with `pipenv shell` and run `ansible-playbook ./generate-cloud-init.yml` there, or you can run commands in the virtual environment from your current shell:

    pipenv run ansible-playbook ./generate-cloud-init.yml

When you no longer need the virtual environment, you can delete it with:

    pipenv --rm

### Running the playbook with Docker

Another alternative to run `ansible-playbook` is to use the [Docker container](https://github.com/CiscoDevNet/sdwan-devops/pkgs/container/sdwan-devops/58460101?tag=cloud) created by the [sdwan-devops](https://github.com/CiscoDevNet/sdwan-devops/tree/cloud) project:

    docker run -it --rm -v $(pwd):/ansible --env PWD="/ansible" ghcr.io/ciscodevnet/sdwan-devops:cloud ansible-playbook ./generate-cloud-init.yml
