#!/bin/bash


# Script settings
MPI_USER='mpiuser'
APT_GET_FLAGS='-qq -y'


function clean_log(){
  rm -f slave.log
}


function write_log(){
  local text=$1
  echo $text >> slave.log 
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


function setting_up_nfs(){
  echo "=> Setting NFS Server"
  write_log "=> Setting NFS Server"

  master_name=${1}
  nfs_dir=${2}

  apt-get $APT_GET_FLAGS update

  if [ $? -eq 0 ]
  then
    echo "Souce list updated succesfully"
    write_log "Souce list updated succesfully"
  else
    echo "Error: Souce list could not be updated" >&2
    write_log "Error: Souce list could not be updated"
  fi

  echo "Installing NFS Client"
  write_log "Installing NFS Client"
  # Install the nfs server package
  apt-get $APT_GET_FLAGS install nfs-common

  echo "Creating NFS shared directory /home/$MPI_USER/$nfs_dir"
  write_log "Creating NFS shared directory /home/$MPI_USER/$nfs_dir"
  # Creating the shared directory
  mkdir -p "/home/$MPI_USER/$nfs_dir"

  echo "Persist $master_name:/home/mpiuser/$nfs_dir mounted directory"
  write_log "Persist $master_name:/home/mpiuser/$nfs_dir mounted directory"
  # To mount the cloud remote folder every time the system starts
  echo "$master_name:/home/mpiuser/$nfs_dir /home/mpiuser/$nfs_dir nfs" >> /etc/fstab

}

function mount_master_shared_dir(){
  echo "=> Mounting remote master:/home/mpiuser/cloud"
  write_log "=> Mounting remote  master:/home/mpiuser/cloud"

  echo "Checking if master host is already configured"
  write_log "Checking if master host is already configured"

  output="$(grep master /etc/hosts | wc -l)"

  # If the host 'master' does not exits in /etc/hosts
  # we add it.
  if [ $output -eq 0 ] # -n not null
  then
    echo "Host 'master' is not defined in /etc/hosts"
    write_log "Host 'master' is not defined in /etc/hosts"
  else
    # Mounting the remote directory on behalf of mpi user
    echo "If the script stops in that step it is possible that the marter is not reachable"
    echo "Please check the master can be reachad from this host"
    output=$(su -c "echo 'mpiuser' | sudo -S mount -t nfs master:/home/mpiuser/cloud /home/mpiuser/cloud" mpiuser)
    
    if [ -z $output ]
    then
      echo "/master:/home/mpiuser/cloud mounted"
      write_log "/master:/home/mpiuser/cloud mounted"
    else
      echo "Error: Remote /master:/home/mpiuser/cloud folder could not be mounted" >&2
      echo "Error: Probably master node is not sharing it" >&2
      write_log "Error: Remote /master:/home/mpiuser/cloud folder could not be mounted"
      write_log "Error: Probably master node is not sharing it"
    fi
  fi
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


function add_master(){
  echo "=> Adding a new host to /etc/hosts"
  write_log "=> Adding a new host to /etc/hosts"

  local host_address=${1}

  host_number="$(grep master_ /etc/hosts | wc -l)"
  output="$(grep $host_address /etc/hosts | wc -l)"

  # If the host_address exits in /etc/hosts
  # we add it.
  if [ $output -eq 0 ] # -n not null
  then
    echo "Adding the master host $host_address to /etc/hosts on master"
    write_log "Adding the master host $host_address to /etc/hosts on master"
    echo -e "$host_address\tmaster_$host_number" >> /etc/hosts
    echo "Master host master_$host_numbe added succesfully"
    write_log "Master host $host_address added succesfully"
  else
    echo "Master host master_$host_numbe already exits" >&2
    write_log "Master hosts $host_address already exits"
  fi

}

function unset_nfs(){
  echo "=> Deleting NFS Mounts"
  write_log "=> Deleting NFS Mounts"
  # Delete lines that contain a pattern
  sed --in-place=.old '/mpiuser/d' /etc/fstab
}

function unset_ssh_keys(){
  echo "=> Deleting SSH keys"
  write_log "=> Deleting SSH keys"
  rm -rf /home/mpiuser/.ssh
}

function unset_etc_hosts(){
  echo "=> Deleting master from /etc/hosts"
  write_log "=> Deleting master from /etc/hosts"
  # Delete lines that contain a pattern
  sed --in-place=.old '/master/d' /etc/hosts
}

# Parsing argumnets
POSITIONAL=''
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -set_master_node)
    HOST_IP="$2"
    add_master $HOST_IP
    shift # past argument
    shift # past value
    ;;
    -config)
    MASTER_NAME="$2"
    NFS_DIR="$3"
    write_log $(date '+%Y-%m-%d %H:%M:%S')
    create_mpi_user
    setting_up_ssh
    setting_up_nfs $MASTER_NAME $NFS_DIR
    mount_master_shared_dir $NFS_DIR
    setting_up_mpi
    shift # past argument
    shift # past value
    shift # past value
    ;;
    -unset)
    unset_nfs
    unset_ssh_keys
    unset_etc_hosts
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

