#!/bin/bash
# setup ssh keys for root which will be used for communication between Control node and other nodes
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -q -f ~/.ssh/id_rsa -N ""
fi

# Enable passwordless autentication from Docker Host to Ansible Control node
base_machine_ssh_pub_key=$(cat base_machine_id_rsa.pub)
grep -q "$base_machine_ssh_pub_key" ~/.ssh/authorized_keys
if [ $? -ne 0 ]; then
    echo "Docker Host User's id_rsa.pub not in ~/.ssh/authorized_keys list. Adding it to enable Passwordless Authentication"
    echo "$base_machine_ssh_pub_key" > ~/.ssh/authorized_keys
    # Disable PasswordAuthentication in sshd_config file
    sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    # Change password for root user to a random string
    randString=$(date|md5sum)
    IFS=" "; randInput=($randString); unset IFS
    randPassword=${randInput[0]}
    echo $randPassword
    echo "root:$randPassword" | chpasswd    
else
    echo "Unable to establish Passwordless Authentication between Docker Host and Ansible Control node!"
fi

# Enable Passwordless Authentication between Ansible Control node and other nodes for Control to Node communication
nodeList=$(cat hosts)
for node in $nodeList
do
    output=$(sshpass -p "screencast"  ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa root@$node)
    if [ ! -z "$output" ]; then
        # Disable PasswordAuthentication and change password on nodes
        cat setup_nodes.sh | ssh root@$node
    fi    
done

# Run SSH in Daemon Mode
/usr/sbin/sshd -D

