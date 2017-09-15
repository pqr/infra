Infrastrcuture repository for otus-devops
=========================================

To start new Google Cloud Platform Instance use following command:
`gcloud compute instances create reddit-app --boot-disk-size=10GB --image=ubuntu-1604-xenial-v20170815a --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone=europe-west1-b --metadata startup-script='wget -O - https://raw.githubusercontent.com/pqr/infra/config-scripts/startup.sh | bash'`