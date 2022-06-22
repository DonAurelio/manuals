#!/bin/bash

#SBATCH --partition=local
#SBATCH --nodelist=galaxy-[1,2]                 # List of nodes to be allocated for the job
#SBATCH --ntasks=1                              # Control de number of tasks to be created for the job (processes==tasks)
#SBATCH --ntasks-per-core=1                     # Control de number of tasks per allocated core.
#SBATCH --cpus-per-task=1                       # In multi-thread process use several cpus.
#SBATCH --time=1:00:00                          # Duraction of the reservation
#SBATCH --output=slurm_%j.out                   # Standard output
#SBATCH --error=slurm_%j.err                    # Standard error
#SBATCH --exclusive

sleep 60