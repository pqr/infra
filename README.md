Infrastrcuture repository for otus-devops
=========================================

To start new Google Cloud Platform Instance use following command:
`gcloud compute instances create reddit-app --boot-disk-size=10GB --image=ubuntu-1604-xenial-v20170815a --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone=europe-west1-b --metadata startup-script='wget -O - https://raw.githubusercontent.com/pqr/infra/config-scripts/startup.sh | bash'`


Create base image:
`cd packer && packer build -var 'project_id=infra-180708' -var 'machine_type=f1-micro' -var 'source_image=ubuntu-1604-xenial-v20170815a' ubuntu16.json`


Create immutable bake image:
`cd packer && packer build -var 'project_id=infra-180708' -var 'machine_type=f1-micro' -var 'source_image=ubuntu-1604-xenial-v20170815a' immutable.json`

To create reddit-app infrastructure using terraform:
```
cd terraform
terraform init
terraform apply
```

Usefull terraform commands:
```
terraform get
terraform plan
terraform show
terraform output
terraform output app_external_ip
terraform taint google_compute_instance.app && terraform apply
terraform apply -auto-approve=false
terraform destroy
```