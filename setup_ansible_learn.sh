# Prepare for Passwordless Authentication between Docker Host and Ansible Control Nodes
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -q -f ~/.ssh/id_rsa -N ""
fi
cp ~/.ssh/id_rsa.pub ./volshare/base_machine_id_rsa.pub
docker-compose -f docker-compose.yml up -d
