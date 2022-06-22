#!/bin/bash

echo "Create munge use for authentication"
export MUNGEUSER=3456
groupadd -g $MUNGEUSER munge
useradd -m -c "MUNGE Uid 'N' Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge -s /sbin/nologin munge

echo "Create slurm user"
export SLURMUSER=3457
groupadd -g $SLURMUSER slurm
useradd -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm -s /bin/bash slurm

echo "Install munge"
apt install -y munge libmunge2 libmunge-dev

echo "Check munge status"
munge -n | unmunge | grep STATUS

echo "Create munge key (This key must be copied to all computing nodes)"
/usr/sbin/create-munge-key -f

echo "Grant the proper permissions to the munge folders"
chown -R munge: /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge
chmod 0700 /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/
chmod 0755 /run/munge/

echo "Enable/Start mungle"
systemctl enable munge
systemctl start munge
munge -n | unmunge

echo "Install slurm workload manager"
apt install -y slurm-wlm

cat << EOF > /etc/slurm-llnl/slurm.conf
# slurm.conf file generated by configurator.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
ClusterName=galaxy.cluster
SlurmctldHost=localhost
MpiDefault=none
ProctrackType=proctrack/linuxproc
ReturnToService=2
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/lib/slurm-llnl/slurmd
SlurmUser=slurm
StateSaveLocation=/var/lib/slurm-llnl/slurmctld
SwitchType=switch/none
TaskPlugin=task/none
#
# TIMERS
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0
# SCHEDULING
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core
#
#AccountingStoragePort=
AccountingStorageType=accounting_storage/none
JobCompType=jobcomp/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=info
SlurmctldLogFile=/var/log/slurm-llnl/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/var/log/slurm-llnl/slurmd.log
#
# COMPUTE NODES
NodeName=localhost CPUs=1 RealMemory=500 State=UNKNOWN
PartitionName=local Nodes=ALL Default=YES MaxTime=INFINITE State=UP
EOF

chmod 755 /etc/slurm-llnl/

echo "Start slurmctld and slurmd"
systemctl start slurmctld
systemctl start slurmd

echo "Set master node status as idle"
scontrol update nodename=localhost state=idle

echo "Status munge"
systemctl status munge

echo "Status slurmctld"
systemctl start slurmctld

echo "Status slurmd"
systemctl start slurmd