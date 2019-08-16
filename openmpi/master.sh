#!/bin/bash

# Script settings
MPI_USER='mpiuser'
APT_GET_FLAGS='-qq -y'
# APT_GET_FLAGS='-qq -y -o Dpkg::Use-Pty=0'


function clean_log(){
  rm -f master.log
}


function write_log(){
  local text=$1
  echo $text >> master.log 
}


# Create and MPI user on the Master node
function create_mpi_user(){
  echo "=> Creating the MPI user $MPI_USER"
  write_log "=> Creating the MPI user $MPI_USER"

  # Adding an MPI user to run MPI jobs
  adduser --disabled-password --gecos "" $MPI_USER
  echo "$MPI_USER:$MPI_USER" | chpasswd
  # make mpiuser sudoer
  usermod -aG sudo $MPI_USER
  # Checking if user was added succesfully
  if [ $? -eq 0 ]
  then
    echo "User $MPI_USER created succesfully"
    write_log "User $MPI_USER created succesfully"
  else
    echo "Error: User $MPI_USER could not be created" >&2
    write_log "Error: User $MPI_USER could not be created"
  fi
}


# Install and start the ssh server
function setting_up_ssh(){
  echo "=> Setting up the ssh server"
  write_log "=> Setting up the ssh server"

  apt-get $APT_GET_FLAGS update

  if [ $? -eq 0 ]
  then
    echo "Souce list updated succesfully"
    write_log "Souce list updated succesfully"
  else
    echo "Error: Souce list could not be updated" >&2
    write_log "Error: Souce list could not be updated"
  fi

  # SSHPASS allor to pass the password to the ssh command
  # without user interaction
  apt-get $APT_GET_FLAGS install sshpass
  # Install the SSH server
  apt-get $APT_GET_FLAGS install openssh-server
  # Running the ssh service
  service ssh start
  # Checking if user was added succesfully
  if [ $? -eq 0 ]
  then
    echo "SSH server running"
    write_log "SSH server running"
  else
    echo "Error: SSH could not be configured" >&2
    write_log "Error: SSH could not be configured"
  fi
}


# Create a private and public ssk keys
function setting_up_ssh_keys(){
  echo "=> Setting up private and public ssh keys"
  write_log "=> Setting up private and public ssh keys"

  # Checking if the mpi ssh key already exists
  if [ -f '/home/mpiuser/.ssh/id_rsa' ]
  then
    echo "You already have an MPI ssh key"
    write_log "You already have an MPI ssh key"
  else
    echo "Creating a folder '/home/mpiuser/.ssh/' to hold MPI SSH keys"
    write_log "Creating a folder '/home/mpiuser/.ssh/' to hold MPI SSH keys"

    # Creating a folder to hold MPI SSH keys
    su -c "mkdir -p /home/mpiuser/.ssh/" ${MPI_USER}

    echo "Creating the private and public ssh keys"
    write_log "Creating the private and public ssh keys"
    # We use su -c "command" mpiuser
    # to run the following commands from 
    # root on behalf of mpiuser 
    # Creationg the public and private keys
    su -c "ssh-keygen -t rsa -N '' -f /home/mpiuser/.ssh/id_rsa" ${MPI_USER}
    # Avoid checking if the remote host is reliable
    su -c "echo 'StrictHostKeyChecking=no' >> /home/mpiuser/.ssh/config" ${MPI_USER}
    # Sharing the public key with myself
    su -c "sshpass -p '${MPI_USER}' ssh-copy-id -i /home/mpiuser/.ssh/id_rsa  localhost" ${MPI_USER}

  fi
  echo "Setting up private and public ssh keys finished succesfully"
  write_log "Setting up private and public ssh keys finished succesfully"
}


function setting_up_mpi(){
  echo "=> Setting up MPI"
  write_log "=> Setting up MPI"

  # Installing OpenMPI library
  apt-get $APT_GET_FLAGS update

  if [ $? -eq 0 ]
  then
    echo "Souce list updated succesfully"
    write_log "Souce list updated succesfully"
  else
    echo "Error: Souce list could not be updated" >&2
    write_log "Error: Souce list could not be updated"
  fi

  apt-get $APT_GET_FLAGS install make openmpi-bin openmpi-doc libopenmpi-dev
  # Checking if mpi was installed succesfully
  if [ $? -eq 0 ]
  then
    echo "MPI was installed succesfully"
    write_log "MPI was installed succesfully"
  else
    echo "Error: MPI can not be installed properly" >&2
    write_log "MPI was installed succesfully"
  fi
}


function setting_up_nfs(){
  echo "=> Setting NFS Server"
  write_log "=> Setting NFS Server"

  apt-get $APT_GET_FLAGS update

  if [ $? -eq 0 ]
  then
    echo "Souce list updated succesfully"
    write_log "Souce list updated succesfully"
  else
    echo "Error: Souce list could not be updated" >&2
    write_log "Error: Souce list could not be updated"
  fi

  echo "Installing NFS Server"
  # Install the nfs server package
  apt-get $APT_GET_FLAGS install nfs-kernel-server

  local nfs_dir="/home/$MPI_USER/${1}"

  echo "Creating NFS shared directory ${nfs_dir}"
  # Creating the shared directory
  mkdir -p "${nfs_dir}"
  # Indicating the directory that will be shared
  # sed -e '/home/mpiuser/cloud *(rw,sync,no_root_squash,no_subtree_check)' -ibak /etc/exports

  output=$(grep "${nfs_dir}" /etc/exports | wc -l)

  if [ $output -eq 0 ]
  then
    echo "${nfs_dir} *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
    # Exporting shared directories
    exportfs -a
    echo "Folder ${nfs_dir} exported"
    write_log "Folder ${nfs_dir} exported"
  else
    echo "Folder ${nfs_dir} was previously expoerted" >&2
    write_log "Folder ${nfs_dir} was previously expoerted"
  fi

  # Restarting the NFS server
  service nfs-kernel-server restart

  if [ $? -eq 0 ]
  then
    echo "NFS server running"
    write_log "NFS server running"
  else
    echo "Error: NFS can not be restarted" >&2
    write_log "Error: NFS can not be restarted"
  fi
}

# Add a Slave in the /etc/hosts file
function add_host(){
  echo "=> Adding a new host to /etc/hosts"
  write_log "=> Adding a new host to /etc/hosts"

  local host_address=${1}

  host_number="$(grep slave_ /etc/hosts | wc -l)"
  output="$(grep $host_address /etc/hosts | wc -l)"

  # If the host_address does not exits in /etc/hosts
  # we add it.
  if [ $output -eq 0 ]
  then
    echo "Adding the ${host_address} IP address with host name slave_$host_number to /etc/hosts on master"
    echo -e "$host_address\tslave_$host_number" >> /etc/hosts
    echo "Host added succesfully"
    write_log "Host added succesfully"
  else
    echo "The hosts $host_address already exits" >&2
    write_log "The hosts $host_address already exits"
  fi
}


# Send the public ssh key to a slave node
function share_ssh_public_key(){
  echo "=> Share public ssh key"
  write_log "=> Share public ssh key"

  local host_address=$1

  # Checking if the mpi ssh key already exists
  if [ -f '/home/mpiuser/.ssh/id_rsa.pub' ]
  then
    echo "Sharing the public key with $host_address"
    write_log "Sharing the public key with $host_address"
    # Sharing the public key with the remote slave
    su -c "sshpass -p '$MPI_USER' ssh-copy-id -i ~/.ssh/id_rsa $MPI_USER@$host_address" ${MPI_USER}
  else
    echo "You dont have ssh keys to share, please use -set_ssh_keys first." >&2
    write_log "You dont have ssh keys to share, please use -set_ssh_keys first."
  fi
}

function unset_nfs(){
  echo "=> Deleting NFS Exports"
  write_log "=> Deleting NFS Exports"
  # Delete lines that contain a pattern
  sed --in-place=.old '/mpiuser/d' /etc/exports

  echo "=> Deleting NFS Exports"
  exportfs -a
}

function unset_ssh_keys(){
  echo "=> Deleting SSH keys"
  write_log "=> Deleting SSH keys"
  rm -rf /home/mpiuser/.ssh
}

function unset_etc_hosts(){
  echo "=> Deleting slave nodes from /etc/hosts"
  write_log "=> Deleting slave nodes from /etc/hosts"
  # Delete lines that contain a pattern
  sed --in-place=.old '/slave/d' /etc/hosts
}


# Parsing argumnets
POSITIONAL=''
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -config)
    NFS_DIR="$2"
    write_log $(date '+%Y-%m-%d %H:%M:%S')
    create_mpi_user
    setting_up_ssh
    setting_up_ssh_keys
    setting_up_nfs $NFS_DIR
    setting_up_mpi
    shift # past argument
    shift # past value
    ;;
    -unset)
    unset_nfs
    unset_ssh_keys
    unset_etc_hosts
    shift # past argument
    # shift # past value
    ;;
    -add_slave)
    HOST_IP="$2"
    add_host $HOST_IP
    share_ssh_public_key $HOST_IP
    shift # past argument
    shift # past value
    ;;
    -set_ssh_keys)
    setting_up_ssh_keys
    shift # past argument
    # shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    echo "The $POSITIONAL arguments is not a valid argument"
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
