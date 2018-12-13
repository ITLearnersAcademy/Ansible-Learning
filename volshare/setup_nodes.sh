echo "Working on node: $(hostname)"
# Disable PasswordAuthentication in sshd_config file
sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Change password for root user to a random string
randString=$(date|md5sum)
IFS=" "; randInput=($randString); unset IFS
randPassword=${randInput[0]}
echo $randPassword
echo "root:$randPassword" | chpasswd

