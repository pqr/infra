# Infrastructure Respitory for learning DevOps tools 


This repository contains a set of configuration files for building an infrastructure for demo Reddit Application in the Google Cloud.
Overview:
1. We will create two base images for Google Compute Engine with preinstalled service software using Packer (https://www.packer.io)  
2. Based on these images we are going to launch virtual machines and set up firewall rules in Google VPC using Terraform (https://www.terraform.io)
3. Next step is to install demo Reddit Application (not ready yet...)

## 0. Prepartion steps
- Create a project in Google Cloud: https://console.cloud.google.com/projectcreate
- Install the Google Cloud Tools (`gcloud` utility): https://cloud.google.com/sdk/docs/
- Initialalize the Google Cloud Tools: `gcloud init`
- Setup Application Default Credentials: `gcloud auth application-default login`
- Install Packer: https://www.packer.io
- Install Terraform: https://www.terraform.io
- Install Ansible http://docs.ansible.com/ansible/latest/intro_installation.html
- Optionally create ssh key: `ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""` (you can skipp this step and yous your existing key)
- Clone this repository on your machine 
 
## 1. Create base images using Packer

### 1.1 Create image with preinstalled MongoDB
Let us build a base image with preinstalled MongoDB (put your Google Cloud project id as the mandatory variable project_id):
```
packer build -var project_id=<your_google_cloud_project_id> packer/db.json
```
Optionally you can pass a few more parameters to change OS, builder machine type and final image name, full example:
```
packer build -var project_id=<your_google_cloud_project_id> -var source_image_family=ubuntu-1604-lts -var machine_type=g1-small -var zone=europe-west1-c -var image_name=myimage_db packer/db.json
```
### 1.2 Create image with preinstalled Ruby and Puma
Second image contains Ruby and Puma (put your Google Cloud project id as the mandatory variable project_id):
```
packer build -var project_id=<your_google_cloud_project_id> packer/app.json
```
Optionally you can pass a few more parameters to change OS, builder machine type and final image name, full example:
```
packer build -var project_id=<your_google_cloud_project_id> -var source_image_family=ubuntu-1604-lts -var machine_type=g1-small -var zone=europe-west1-c -var image_name=myimage_app packer/app.json
```

## 2. Setup infrastructure with Terraform
This repository contains two different infrastructure descriptions: for Staging and for Production.

### 2.1 Setup Staging infrastructure
Create a new bucket in Google Cloud Storage: https://console.cloud.google.com/storage/create-bucket - put any bucket name there and remember it. This bucket is needed as backend for Terraform state.

Then enter into `terraform/stage` dir (from root of this repository):
```
cd terraform/stage
```

There are two exmaple configuration files.  and `terraform.tfvars.example`

First one is `gsc-backend.tf.example` - rename it to `gsc-backend.tf` and put your own parameters: 
- **bucket** - your Google Cloud Storage bucket name
- **project** - your Google Cloud Project ID

Second configuration file is `terraform.tfvars.example` - rename it to `terraform.tfvars` and put your own parameters:
- **project** - your Google Cloud Project ID
- **public_key_path** and **private_key_path** - paths to your ssh key to be used to connect to created virtual machines 
- **db_disk_image** and **app_disk_image** - disk image names created with packer (you can leave default values "reddit-db" and "reddit-app" if you did not specifiy you own names while running packer)

Next initialize Terraform and create actual Staging infrastructure on Google Cloud:
```
terraform init
terraform apply
```

### 2.1 Setup Production infrastructure
Create a new bucket in Google Cloud Storage: https://console.cloud.google.com/storage/create-bucket - put any bucket name there and remember it. This bucket is needed as backend for Terraform state.

Then enter into `terraform/prod` dir (from root of this repository):
```
cd terraform/prod
```

Then rename `gsc-backend.tf.example` to `gsc-backend.tf` and `terraform.tfvars.example` to `terraform.tfvars`.
Put your parameters into `gsc-backend.tf` and `terraform.tfvars` as described in previous section for Staging.

The only difference Production from Staging infrastructure is that in Production you can restrict ssh access to prodction server with your client public ip in `terraform.tfvars`, example:
```
ssh_source_ranges = ["31.13.17.20/32"];
```

Finnaly, initialize Terraform and create actual Production infrastructure on Google Cloud:
```
terraform init
terraform apply
```

## 3. Deploy Reddit application with Ansible

Assume we successfully installed Staging infrastructure using Terraform.
First we need to know some IP addreeses.
Enter into `terraform/stage` dir (from root of this repository) and run `terraform show` command:
```
cd terraform/stage
terraform show
```
as a result we can see 3 IP addresses:
```
Outputs:

app_external_ip = 130.211.97.45
db_external_ip = 35.195.167.75
db_internal_ip = 10.132.0.2
```

Enter into `ansible` dir:
```
cd ../../ansible
```

Edit `environments/stage/hosts` file (path relative to `ansible` dir): replace external IP addresses for `appserver` and `dbserver` with outputed by terraform.
In this example `hosts` will look like:
```
[app]
appserver ansible_ssh_host=130.211.97.45
[db]
dbserver ansible_ssh_host=35.195.167.75
```

Next edit `environments/stage/group_vars/app` file: replace IP address in variable `db_host` with IP address shown by terraform as `db_internal_ip` (in this example: `db_host: 10.132.0.2`).


Then install roles used in playbooks with `ansible-galaxy` utility:
```
ansible-galaxy install -r requirements.yml
```

Run ansible playbooks to deploy on **stage** environment:
```
ansible-playbook site.yml --check
ansible-playbook site.yml
```

To deploy on **prod** environment, do the same steps:
1. Don't forget to destroy Staging infrastructure first using `terraform destroy` command from `terraform/stage` dir
2. Install Production infrastructure using `terraform apply -auto-approve=false` command from `terraform/prod` dir
3. Copy ip addresses outputed by terraform into `environments/prod/hosts` and `environments/prod/group_vars/app` (as we did it in stage example)
4. Run ansible playbook with explicit environment (from `ansible` dir): 
```
ansible-playbook -i environments/prod/hosts site.yml --check
ansible-playbook -i environments/prod/hosts site.yml
```

## 4. Test Ansible playbooks with Molecule and Testinfra

### 4.1 Preparation steps (setup with virtualenv)

It's better to use Molecule within local Python environment using `virtualenv`.
1. Install `virtualenv`: http://docs.python-guide.org/en/latest/dev/virtualenvs/
2. Enter into `ansible` directory in this repository: `cd ansible`
3. Create virtual environment here: `virtualenv .`
4. Activate virtual environment: `source bin/activate`
5. Install Ansible 2.3, Molecule and Testinfra into current virtual environment `pip install -r requirements.txt`
6. Check Molecule version: `molecule --version` - should be 2.1.0
7. Check Ansible version `ansible --version` - should be 2.3.2.0

### 4.2 Actual testing Ansible playbooks
```
cd roles/db
molecule init scenario --scenario-name default -r db -d vagrant
molecule create
molecule converge
molecule verify
```
