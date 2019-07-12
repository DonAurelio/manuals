# htcondor-tutorial

This repository contains basic examples to learn how to use htcondor. You can install a customized version of HTCondor on your computer to reproduce the examples found in this repository.

## Install HTCondor Personal Pool (Ubuntu)

Download the HTCondor deb package [condor_8.6.11-440910-ubuntu14_amd64.deb](https://research.cs.wisc.edu/htcondor/downloads/?state=select_from_mirror_page&version=8.6.11&mirror=UW%20Madison&optional_organization_url=http://). 

To install HTCondor, start the **root** session.

```sh
sudo su root
```

Install HTCondor from .deb package.

```sh
dpkg -i condor_8.6.11-440910-ubuntu14_amd64.deb
```

In case failures by missing dependencies use.

```sh
apt-get install -f
```

Configure your machine to Submit, Execute and Manage HTCondor Jobs. Create/Edit the */etc/condor/condor_config.local* file. 

```sh
nano /etc/condor/condor_config.local
```

Paste the following content

```sh
QUEUE_ALL_USERS_TRUSTED = TRUE
ALLOW_READ = *
ALLOW_WRITE = *
HOSTALLOW_READ = *
HOSTALLOW_WRITE = *
ALLOW_NEGOTIATOR = *
ALLOW_ADMINISTRATOR = *
COLLECTOR_DEBUG = D_FULLDEBUG
NEGOTIATOR_DEBUG = D_FULLDEBUG
MATCH_DEBUG = D_FULLDEBUG
SCHEDD_DEBUG = D_FULLDEBUG
START = TRUE
TRUST_UID_DOMAIN = TRUE
USE_SHARED_PORT=FALSE
```

Restart HTCondor 

```sh
nano /etc/init.d/condor restart
```

Check if HTCondor is working. 

```sh
condor_status
```

The above command will display the output shown below. If nothing appears, please give a second to HTCondor to recognize your PC resources and try to perform the command again.  

```sh
Name         OpSys      Arch   State     Activity LoadAv Mem   ActvtyTime

slot1@leader LINUX      X86_64 Unclaimed Idle      0.000  956  0+00:03:20
...


                     Total Owner Claimed Unclaimed Matched Preempting Backfill  Drain

        X86_64/LINUX     4     0       0         4       0          0        0      0

               Total     4     0       0         4       0          0        0      0

```

## Support for Docker Containers

Continue as **root** user. Install *docker.io*

```sh
apt-get install docker.io
```

Add the **condor** user to the docker group.

```sh
usermod -aG docker condor
```

Start/restart docker service.

```sh
service docker restart
```

Restart the HTCondor service.

```sh
/etc/init.d/condor restart
```

Check if HTCondor **HasDocker** ClassAdd is set to **true**.

```sh
condor_status -long | grep HasDocker
```

The above command will display the output shown below.

```sh
...
HasDocker = true
StarterAbilityList = "HasEncryptExecuteDirectory,HasJava,HasDocker,HasFileTransfer,HasTDP,HasPerFileEncryption,HasVM,HasReconnect,HasMPI,HasFileTransferPluginMethods,HasJobDeferral,HasJICLocalStdin,HasJICLocalConfig,HasRemoteSyscalls,HasCheckpointing"
...
```

Close the root session.

```sh
exit
```

## Remove HTCondor

You have to remove HTcondor, start the **root** session. 

```sh
sudo su root
```

Install HTCondor from .deb package.

```sh
dpkg --remove --force-remove-reinstreq condor
```

To remove the configuration files.

```sh
dpkg --purge --force-remove-reinstreq condor
```

```sh
exit
```

## Remove Docker.io

Continue as **root** user. Remove docker.io

```sh
apt-get remove --purge docker.io
```

```sh
exit
```

# References

1. HTCondor Version 8.6.11 Manual
2. Course of Introduction to Large Scale Computing Infrastructures Spring2017 - John Sanabria, Universidad del Valle, Cali, Colombia.