#!/bin/bash
#! This line is a comment
#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J mong_julia
#! Account name for group, use SL2 for paying queue:
#SBATCH -A JOHNSTONE-SL3-CPU
#! Output filename:
#! %A means slurm job ID and %a means array index
#SBATCH --output=test_mong_%A_%a.out
#! Errors filename:
#SBATCH --error=mong_julia_%A_%a.err

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task. (for single core jobs always leave this at 1)
#SBATCH --ntasks=1
#! How many many cores will be allocated per task? (for single core jobs always leave this at 1)
#SBATCH --cpus-per-task=1
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=01:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#! RAM is allocated in ~5980mb blocks, you are charged per block used,
#! and unused fractions of blocks will not be usable by others.
#SBATCH --mem=3420mb
#! Submit a job array with index values between 0 and 31
#! NOTE: This must be a range, not a single number (i.e. specifying '32' here would only run one job, with index 32)
#SBATCH --array=1-8640

#! This is the partition name.
#SBATCH -p skylake,cclake

#! mail alert at start, end and abortion of execution
#! emails will default to going to your email address
#! you can specify a different email address manually if needed.
#SBATCH --mail-user=matis.patel+hpc@gmail.com
#SBATCH --mail-type=All

#! Don't put any #SBATCH directives below this line

#! Modify the environment seen by the application. For this example we need the default modules.
. /etc/profile.d/modules.sh                # This line enables the module command
module purge                               # Removes all modules still loaded
module load rhel7/default-peta4            # REQUIRED - loads the basic environment
# module load miniconda/3
source ~/.bashrc
# activate environment
# conda activate /home/mmp38/mongooses/mongenv
#! The variable $SLURM_ARRAY_TASK_ID contains the array index for each job.
#! In this example, each job will be passed its index, so each output file will contain a different value
echo "This is job" $SLURM_ARRAY_TASK_ID
#! Command line that we want to run:
julia --project simulationHPC.jl

# jobDir=Job_$SLURM_ARRAY_TASK_ID_$SLURM_JOBID
# mkdir $jobDir
# cd $jobDir

# python3 ../cluster_53.py $SLURM_ARRAY_TASK_ID
# squeue -h -j $SLURM_JOBID -o "%L"