#!/usr/bin/env bash
FSC_BASENAMES=(
    "s3-msc"
    "s3-msci-ghost"
    "s3-msci-inflow"
    "s3-msci-outflow"
    "s3-mscm-inflow"
    "s3-mscm-outflow"
)

for((i=1;i<=120;i++));do
    # This block is now wrapped in parentheses, creating a subshell
    (
        MODEL_INDEX=$((($i - 1) % 6 ))
        FSC_MODEL=${FSC_BASENAMES[$MODEL_INDEX]}

        # This cd only affects the subshell
        cd "task_$i/sfs/fsc/${FSC_MODEL}"
        echo "INFO: Now in $(pwd), submitting jobs for ${FSC_MODEL}..."

        for((j=1;j<=50;j++));do
                # This cd also only affects the subshell
                (
                    cd "${FSC_MODEL}_$j"
                    qsub part2.sh
                ) # This inner subshell is also a good practice
        done

        echo "INFO: Finished submissions for task $i."
    ) # The subshell exits here. The main script's directory is unchanged.
done

echo "All submission loops are complete."
