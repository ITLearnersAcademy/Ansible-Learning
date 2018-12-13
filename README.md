# Ansible-Learning
Short Description: Quickly setup a learning play ground for Ansible
Version: 2
Tested: Ubuntu 16.04.2 desktop. Should be working on any Linux/Mac OS machine. Feedbacks welcome!
Long Description: End to end automation to setup one Ansible Control host and 2 nodes with passwordless authentication enabled for these nodes from a Docker Host

Prerequisites:
On your base machine or development desktop, below packages needs to be installed:
Docker version: 18.09.0 or higher
Docker-compose version: 1.23.1 or higher
Note: This should be working on any of the recent versions of Docker or Compose. For example: Docker release 17 or higher but I have used the latest versions for my dev and testing.

Setup Instructions:
git clone https://github.com/ITLearnersAcademy/Ansible-Learning.git
cd Ansible-Learning
./setup_ansible_learn.sh 

Usage Instructions:
Open Terminal on your machine
To connect to Ansible Control host: ssh root@ansible-control
To connect to nodes from Control host: ssh root@node1 or ssh root@node2
Note: You can only connect to nodes from the control host and won't be able to connect directy from your Docker Host
