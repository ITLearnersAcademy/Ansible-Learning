echo "Working on node: $(hostname)"
# create a normal user with sudo privileges if user doesn't exist
grep -q "ansible" /etc/passwd
if [ $? -ne 0 ]; then
    useradd -d /home/ansible -m -s /bin/bash -p ansible ansible
    usermod -aG sudo ansible
    mkdir /home/ansible/.ssh
    ssh-keygen -q -f /home/ansible/.ssh/id_rsa -N ""
    sed -i "s/root@$(hostname)/ansible@$(hostname)/" /home/ansible/.ssh/id_rsa.pub
fi

# Enable passwordless autentication from Control Host to node
control_machine_ssh_pub_key=$(cat /workspace/control_machine_id_rsa.pub)
grep -q "$control_machine_ssh_pub_key" /home/ansible/.ssh/authorized_keys
if [ $? -ne 0 ]; then
    echo "Control Host ansible User's id_rsa.pub not in /home/ansible/.ssh/authorized_keys list. Adding it to enable Passwordless Authentication"
    echo "$control_machine_ssh_pub_key" > /home/ansible/.ssh/authorized_keys
    # Disable PasswordAuthentication in sshd_config file as root user
    sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    # Change password for root,ansible user to a random string
    randString=$(date|md5sum)
    IFS=" "; randInput=($randString); unset IFS
    randPassword=${randInput[0]}
    echo "------------Make Note:------------------------"
    echo "Ansible and Root user's password ($hostname): $randPassword"
    echo "----------------------------------------------"
    echo "root:$randPassword" | chpasswd
    echo "ansible:$randPassword" | chpasswd
    chown -R ansible:ansible /home/ansible/.ssh/
else
    echo "Passwordless Authentication between Ansible Control host and node already established!"
fi

