# Configuring a MPI Cluster Over a LAN

This folder contains configuration scripts to configure manually a LAN MPI Cluster of two machines. i.e., a single master and slave node.

## Requirements

* Master and Slave machines need communicated over the network
* The scripts must be run as root user.

## Configuration Steps

The following configuration scripts have the following format: <machine>.sh. i.e., the slave.sh is the script that must be used in a **slave node**.

**NOTE: Run the following scripts under the root user**

Setting up the Master and Slave nodes

1. Configure the Master and Slave nodes: the configuration create an mpiuser, setting up ssh, ssh keys, nfs and mpi.

```sh
./master.sh -config
```

Run this on slave nodes

```sh
./slave.sh -config
```

2. Configure the Slave Node: create an mpiuser, setting up ssh, mpi, add the Master Node Address to /etc/hosts, and mount the master remove /home/mpi/cloud shared network directory.

```sh
./slave.sh -set_master_node master_ip -mount_master_dir
```

3. Add configured Slave Nodes to the Master

```sh
./master.sh -add_slave new_slave_ip
```

For every new Slave Node perform steps 2 and 3.

## References

[Running an MPI Cluster within a LAN](http://mpitutorial.com/tutorials/running-an-mpi-cluster-within-a-lan/)
[How do I parse command line arguments in Bash?](https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash)