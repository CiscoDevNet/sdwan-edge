# Catalyst 8000v deployment on Opnestack

Deployment of the c8kv on Openstack with basic onfiguration and onboarding in the SDWAN CP

![C8KV Deployment](../../cedge_deployment.png)

The scripts will deploy and onboard a Catalyst 8000V on Openstack using existing networks. Following items will be created:

- Single C8000v instance with a transport interface and a service interface. Basic configuration to connect to an existing SD-WAN Fabric.

The scripts will create a new c8kv instance from an existing image. Creating the image from the Catalyst 8000v qcow2 image file can be done using the provided terraform script.

## Terraform - Authenticating to Openstack

Openstack authentication details like credentials file and selected profile need to be specified into openstack/openstack.tf

## Create the Openstack image

The the scripts will create an based on the c8kv qcow image file.

- Go to image directory
- Edit c8kv_image.tf with appropriate settings.

The qcow source can be:

- a remote url, specified using image_source_url. The optional web_download controls if the image is directly downloaded form the specified URL by Openstack or not - in which case it is first downloaded local
- a local file, specified by local_file_path

With image as your current working directory, run terraform:

    terraform init
    terraform plan
    terraform apply

## Create c8000v in Openstack

The 2 needed networks - transport and service - are expected to already exist. Also be sure to have the necessary cloud-init file under the cloud-init directory - use the provided ansible script under GenerateCloudInit to generate it.

Deploy Cisco SD-WAN C8000v in the VPC network:

- Go to cedge directory
- Edit variables.auto.tfvars.json with appropriate settings.

The complete list of input variables:

- name -  name of the deployed instance
- image_name - name of the c8kv image on openstack
- flavor_name - flavor name of the created instance
- subnet_transport - name of the network to be used for the transport interface
- subnet_service -  name of the network to be used for the service interface

Terraform deployment:

    terraform init
    terraform plan
    terraform apply

## Termination

To terminate c8000v instances, go to the cedge directory and run:

    terraform destroy --auto-approve
