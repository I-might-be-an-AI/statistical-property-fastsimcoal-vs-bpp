#!/bin/bash -l
#$ -cwd
#$ -l tmem=2G
#$ -l h_vmem=2G
#$ -l h_rt=3000
#$ -S /bin/bash
#$ -j y
#$ -N sfs_data_job
#$ -t 1-120
set -e
set -u
set -o pipefail

FSC_BASENAMES=(
    "s3-msc"
    "s3-msci-ghost"
    "s3-msci-inflow"
    "s3-msci-outflow"
    "s3-mscm-inflow"
    "s3-mscm-outflow"
)

MODEL_INDEX=$(( (SGE_TASK_ID - 1) % 6 ))
FSC_MODEL=${FSC_BASENAMES[$MODEL_INDEX]}

echo "========================================================"
echo "INFO: Job starting on host: $(hostname)"
echo "INFO: SGE Task ID: $SGE_TASK_ID"
echo "========================================================"

WORKDIR="task_${SGE_TASK_ID}"
mkdir -p $WORKDIR
echo "INFO: Created unique workspace: $WORKDIR"
mkdir -p $WORKDIR/bootstrapped

cp -r sfs $WORKDIR/
cd $WORKDIR/sfs
cd fsc

fsc28 -i ${FSC_MODEL}.par -n1 --quiet --dsfs -s0 --jobs -b50 --seed $SGE_TASK_ID
for ((i=1;i<=50;i++));do
    cp part2.sh ${FSC_MODEL}/${FSC_MODEL}_$i/
    cp ${FSC_MODEL}.tpl ${FSC_MODEL}.est ${FSC_MODEL}/${FSC_MODEL}_$i/
done
echo "copie of part2.sh complete"
echo "Run next script"


