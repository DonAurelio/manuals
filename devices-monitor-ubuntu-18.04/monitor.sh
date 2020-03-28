#! /bin/bash

# Autor: Aurelio Vivas <aa.vivas@uniandes.edu.co>

# HOW TO RUN THIS SCRIPT
# ./monitor.sh

# USE THIS SCRIPT AS A CRONJOB
# crontab -e 
# */1 * * * * /home/<your-user>/monitor/monitor.sh -cpu -memory -disk <disk_name> -network <device_name> [-gpu] >> /home/<your-user>/monitor/out.log 2>> /home/<your-user>/monitor/err.log
# To list existing cron jobs:
# crontab –l
# To remove an existing cron job:
# Enter: crontab –e
# Delete the line that contains your cron job
# Hit ESC > :w > :q

DATE=$(date '+%Y-%m-%d %H:%M:%S')
METRICS="$DATE"

function cpu_metrics(){
    CPU_USAGE=$(mpstat 1 1 | grep Average | awk 'NR==1{printf "%s",$3}')
    CPU_COUNT=$(nproc --all)
    
    METRICS="$METRICS;$CPU_USAGE;$CPU_COUNT"
}

function memory_metrics(){
    # Place main memory statistics in Megabytes
    MEM_TOTAL=$(free -m -t | grep Total | awk 'NR==1{printf "%s",$2}')
    MEM_USED=$(free -m -t | grep Total | awk 'NR==1{printf "%s",$3}')
    
    METRICS="$METRICS;$MEM_TOTAL;$MEM_USED"
}

function disk_metrics(){
    disk_device_name=${1}
    # The number of kilobytes read from the device per second.
    DISK_READS=$(iostat -x -d ${disk_device_name} 1 2 | grep ${disk_device_name} | awk 'NR==2{printf "%s",$4}')
    # The number of kilobytes written to the device per second.
    DISK_WRITES=$(iostat -x -d ${disk_device_name} 1 2 | grep ${disk_device_name} | awk 'NR==2{printf "%s",$5}')
    # Percentage of CPU time during which I/O requests were issued to the device (bandwidth utilization for the device). 
    # Device saturation occurs when this value is close to 100%.
    DISK_USAGE=$(iostat -x -d ${disk_device_name} 1 2 | grep ${disk_device_name} | awk 'NR==2{printf "%s",$16}')
    
    METRICS="$METRICS;$DISK_READS;$DISK_WRITES;$DISK_USAGE"
}

function network_metrics(){
    network_device_name=${1}
    # Kilobytes/second read (received).
    NET_READS=$(nicstat -i ${network_device_name} -s 1 2 | awk 'NR==3{printf "%s",$3}')
    #  Kilobytes/second written (transmitted).
    NET_WRITES=$(nicstat -i ${network_device_name} -s 1 2 | awk 'NR==3{printf "%s",$4}')

    METRICS="$METRICS;$NET_READS;$NET_WRITES"
}

function gpu_metrics(){
    # GPU METRICS
    # -timesptamp: The timestamp of where the query was made in format "YYYY/MM/DD HH:MM:SS.msec".
    # GPU_TIMESTAMP=$(nvidia-smi --query-gpu=timestamp --format=csv,noheader,nounits | awk 'NR=1{printf "%s %s\t",$1,$2}')
    # -name: The official product name of the GPU. This is an alphanumeric string. For all products.
    # GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | awk 'NR=1{printf "%s %s %s\t",$1,$2,$3}')
    # -driver_version: The version of the installed NVIDIA display driver. This is an alphanumeric string.
    # GPU_DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')
    # -pstate: The current performance state for the GPU. States range from P0 (maximum performance) 
    #   to P12 (minimum performance).
    GPU_PST=$(nvidia-smi --query-gpu=pstate --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')
    # -temperature.gpu: Core GPU temperature. in degrees C.
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')
    # -utilization.gpu: Percent of time over the past sample period during which one or more kernels was
    #   executing on the GPU. The sample period may be between 1 second and 1/6 second depending on the product.
    GPU_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')
    # -utilization.memory: Percent of time over the past sample period during which global (device) memory
    #   was being read or written. The sample period may be between 1 second and 1/6 second depending on the product.
    GPU_MEMORY_USAGE=$(nvidia-smi --query-gpu=utilization.memory --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')
    # -memory.total: Total installed GPU memory.
    GPU_MEMORY_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')
    # -memory.used: Total memory allocated by active contexts.
    GPU_MEMORY_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')
    # -memory.free: Total free memory.
    # GPU_MEMORY_FREE=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | awk 'NR=1{printf "%s\t",$1}')

    METRICS="$METRICS;$GPU_USAGE;$GPU_MEMORY_TOTAL;$GPU_MEMORY_USED;$GPU_PST;$GPU_TEMP"
}



# Parsing argumnets
POSITIONAL=''
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -cpu)
    cpu_metrics
    shift # past argument
    # shift # past value
    ;;
    -gpu)
    gpu_metrics
    shift # past argument
    # shift # past value
    ;;
    -memory)
    memory_metrics
    shift # past argument
    # shift # past value
    ;;
    -disk)
    disk_name="$2"
    disk_metrics $disk_name    
    shift # past argument
    shift # past value
    ;;
    -network)
    nic_name="$2"
    network_metrics $nic_name
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    echo "The $POSITIONAL arguments is not a valid argument"
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo $METRICS