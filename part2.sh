#!/bin/bash -l
#$ -cwd
#$ -l tmem=1G
#$ -l h_vmem=1G
#$ -l h_rt=3600
#$ -S /bin/bash
#$ -j y
#$ -N parameter_estimates
#$ -t 1-10
set -euo pipefail
#Try runnning this maybe for 20 at a time, then run part3 to clear up storage before next batch
mkdir -p boot_results/
dir_name=$(basename "$(cd ../../../../ && pwd)")
ID="${dir_name#*_}"
boot_name=$(basename "$(pwd)")
boot_ID="${boot_name#*_}"

FSC_BASENAMES=(
    "s3-msc"
    "s3-msci-ghost"
    "s3-msci-inflow"
    "s3-msci-outflow"
    "s3-mscm-inflow"
    "s3-mscm-outflow"
)

MODEL_INDEX=$(( (ID - 1) % 6 ))
FSC_MODEL=${FSC_BASENAMES[$MODEL_INDEX]}

mkdir -p estimate_${SGE_TASK_ID}
cp *.obs estimate_${SGE_TASK_ID}/
cp ${FSC_MODEL}.tpl ${FSC_MODEL}.est estimate_${SGE_TASK_ID}/

cd estimate_${SGE_TASK_ID}/

fsc28 -t ${FSC_MODEL}.tpl -e ${FSC_MODEL}.est -n100000 -d -M -l 10 -L 40 -y 5 -q -r ${SGE_TASK_ID}
mv ${FSC_MODEL}/${FSC_MODEL}.bestlhoods ${FSC_MODEL}.bestlhoods_boot${boot_ID}_${SGE_TASK_ID}
mv ${FSC_MODEL}.bestlhoods_boot${boot_ID}_${SGE_TASK_ID} ../boot_results/
cd ..
rm -rf estimate_${SGE_TASK_ID}
echo "done"

