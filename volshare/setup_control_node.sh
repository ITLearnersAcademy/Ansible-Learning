#!/bin/bash
# create ansible user for the normal operations
# setup ssh keys for ansible user which will be used for communication between Control node and other nodes
grep -q "ansible" /etc/passwd
if [ $? -ne 0 ]; then
    useradd -d /home/ansible -m -s /bin/bash -p ansible ansible
    usermod -aG sudo ansible
    mkdir /home/ansible/.ssh
    ssh-keygen -q -f /home/ansible/.ssh/id_rsa -N ""
    sed -i 's/root@control.ansiblelearn.io/ansible@control.ansiblelearn.io/' /home/ansible/.ssh/id_rsa.pub
    cp /home/ansible/.ssh/id_rsa.pub /workspace/control_machine_id_rsa.pub
fi

# Enable passwordless autentication from Docker Host to Ansible Control node
base_machine_ssh_pub_key=$(cat /workspace/base_machine_id_rsa.pub)
grep -q "$base_machine_ssh_pub_key" /home/ansible/.ssh/authorized_keys
if [ $? -ne 0 ]
then
    echo "Docker Host User's id_rsa.pub not in /home/ansible/.ssh/authorized_keys list. Adding it to enable Passwordless Authentication"
    echo "$base_machine_ssh_pub_key" > /home/ansible/.ssh/authorized_keys
    # Disable PasswordAuthentication in sshd_config file
    sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    # Change password for root, ansible users to a random string
    randString=$(date|md5sum)
    IFS=" "; randInput=($randString); unset IFS
    randPassword=${randInput[0]}
    echo "Random Password $randPassword"
    echo "root:$randPassword" | chpasswd
    echo "ansible:$randPassword" | chpasswd
    chown -R ansible:ansible /home/ansible/.ssh/    
else
    echo "Passwordless Authentication between Docker Host and Ansible Control node already established!"
fi

# Enable Passwordless Authentication between Ansible Control node and other nodes for Control to Node communication
nodeList=$(cat hosts)
for node in $nodeList
do
    # Disable PasswordAuthentication and change password on nodes
    echo "Enabling Passwordless Authentication between Ansible Control node and other nodes for Control to Node communication"
    cat setup_nodes.sh | sshpass -p "screencast" ssh -o "StrictHostKeyChecking no" root@$node
done

# Run SSH in Daemon Mode
/usr/sbin/sshd -D

