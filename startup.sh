wget -O - https://raw.githubusercontent.com/pqr/infra/config-scripts/install_ruby.sh | sudo -u appuser -i bash
wget -O - https://raw.githubusercontent.com/pqr/infra/config-scripts/install_mongodb.sh | bash
wget -O - https://raw.githubusercontent.com/pqr/infra/config-scripts/deploy.sh | sudo -u appuser -i bash