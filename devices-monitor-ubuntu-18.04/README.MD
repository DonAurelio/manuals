


## Requirements 

* sysstat and nicstat

```sh
sudo apt-get install sysstat nicstat
```

## CPU Activity

**mpstat** *Linux command is a utility that collects and displays information about CPU utilization and performance statistics.* If you run mpstat with no arguments it will display an average CPU statistics since the computer was up. Probably we don't 

```sh
mpstat 1 1
```

This command displays the following report. We are intereted in the last report (Total).

```sh
11:29:20     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
11:29:21     all   12,12    0,00    5,56    0,00    0,00    1,26    0,00    0,00    0,00   81,06
Average:     all   12,12    0,00    5,56    0,00    0,00    1,26    0,00    0,00    0,00   81,06
```

We can be interested in:

* **%usr** - *Percentage of CPU utilization that occurred while executing at the user level which includes application processes, user running jobs, etc.*


In some cases you will require to get the number of processing units avaibale on your system.

```sh
nproc --all
```

## Memory Activity

**free** displays the total amount of free and used physical and swap memory in the system.

* -m (megabytes) switch displays it in megabytes.
* -t (totals) switch displays a line containing the totals (mem + swap).

```sh 
free -m -t
```

This command displays the following report. We are intereted in the last report (Total).

```sh
              total        used        free      shared  buff/cache   available
Mem:           7680        4661        1505         185        1513        2567
Swap:           975           0         975
Total:         8656        4661        2480
```


## Disk Activity

*iostat - Report Central Processing Unit (CPU) statistics and input/output statistics for devices, partitions and network filesystems (NFS).* **iostat** display extended stadistics (-x) regarding device (sda) disk usage. This command will display 2 reports of 1 second interval (the number of seconds iostat waits for each report).

* -x display extended disk utilization report
* -d display only disk utilization report

```sh
iostat -x -d sda 1 2
```

The first report iostat displays is an stadistic since the system was up (first two rows). The second one is the current activity on disk per second. 

```sh
# Statdistics since the sistemas was up
Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %rrqm  %wrqm r_await w_await aqu-sz rareq-sz wareq-sz  svctm  %util
sda             11,76    8,49    180,65   1623,89     2,93     6,73  19,96  44,24   33,46  415,67   3,92    15,36   191,32   4,70   9,52
# Stadistics collected during last 1 second
Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %rrqm  %wrqm r_await w_await aqu-sz rareq-sz wareq-sz  svctm  %util
sda              0,00    0,00      0,00      0,00     0,00     0,00   0,00   0,00    0,00    0,00   0,00     0,00     0,00   0,00   0,00
```

We can be interested in:

* **rkB/s** - *The number of kilobytes read from the device per second.*
* **wkB/s** - *The number of kilobytes written to the device per second.*
* **%util** - *Percentage of CPU time during which I/O requests were issued to the device (bandwidth utilization for the device). Device saturation occurs when this value is close to 100%.*

## Network Activity

**nicstat** - *print network traffic statistics.* This command will display 2 reports of 1 second interval (the number of seconds iostat waits for each report).

* -i (interface) network interface to monitor
* -s (summary) display only read and write kB/s. 

```sh
nicstat -i wlp2s0 -s 1 2
```

The first report nicstat display an stadistic since the system was up (first two rows). The second one is the current activity on networking device per second.

```sh
    Time      Int          rKB/s          wKB/s
# Statdistics since the sistemas was up
10:20:23   wlp2s0          8.399          1.581
# Stadistics collected during last 1 second
10:20:24   wlp2s0          0.000          0.000
```

We can be interested in:

* **rkB/s** - *Kilobytes/second read (received).*
* **wkB/s** - *Kilobytes/second written (transmitted).*

## NVIDA GPU Activity

A complete guide about the commands you can use to measure GPU performance using nvidia-smi can be found [here](https://nvidia.custhelp.com/app/answers/detail/a_id/3751/~/useful-nvidia-smi-queries).

# References 

- [Basic I/O Monitoring On Linux](https://blog.pythian.com/basic-io-monitoring-on-linux/)
- [iostat(1) - Linux man page](https://linux.die.net/man/1/iostat)
- [nicstat (1)](https://docs.oracle.com/cd/E86824_01/html/E54763/nicstat-1.html)
- [SOLARIS: NICSTAT COMMAND SHOW NETWORK INTERFACE CARD STATICS](https://hosam.wordpress.com/2014/10/02/solaris-nicstat-command-show-network-interface-card-statics/)
- [free - Unix, Linux Command](https://www.tutorialspoint.com/unix_commands/free.htm)
- [7 MPSTAT COMMAND EXAMPLES IN LINUX](https://www.linuxnix.com/7-mpstat-command-examples-in-linux/)
- [Useful nvidia-smi Queries](https://nvidia.custhelp.com/app/answers/detail/a_id/3751/~/useful-nvidia-smi-queries)
