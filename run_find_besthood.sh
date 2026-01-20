for (( i=1; i<=40; i++ )); do
  (
    cd "task_${i}/sfs/fsc_results"  || { echo "task_$i missing" >&2; exit 1; }
    ./find_besthood.sh
  ) &
done
