#!/usr/bin/env bash
shopt -s nullglob

# Get the full path of the parent directory
parent_dir_path=$(dirname "$(pwd)")

# Get just the name of the parent directory
parent_dir_name=$(basename "$parent_dir_path")

# Use parameter expansion to strip non-digits from the front
run_number=${parent_dir_name##*[^0-9]}



glob=${1:-'*bestlhoods*'}
files=( $glob )

(( ${#files[@]} )) || { echo "No files match '$glob'" >&2; exit 1; }

min_diff=''
best_file=''

for f in "${files[@]}"; do
  # absolute difference between the last two fields of line 2
  diff=$(
    awk '
      NR==2 {
	if (NF < 2) exit 2               # not enough columns
        d = $(NF-1) - $NF
        print (d < 0 ? -d : d)
        exit
      }
    ' "$f"
  )

  # first file → seed the trackers
  if [[ -z $min_diff || $(awk -v d="$diff" -v m="$min_diff" 'BEGIN{print(d<m)}') -eq 1 ]]; then
    min_diff=$diff
    best_file=$f
  fi
done

printf 'Best file : %s\nMin |Δ|   : %s\n' "$best_file" "$min_diff"
if [[ ! -e "$best_file" ]]; then
  echo "Error: best file '$best_file' not found!" >&2
  exit 1
fi

# Remove all files except the winner
for f in *bestlhoods*; do
  [[ $f == $best_file ]] || rm -v "$f"
done

echo "Kept file: $best_file (|Δ| = $min_diff)"

mv $best_file $parent_dir_name
mv $parent_dir_name ../../../bootstrapped

echo "YEAAHHHH"
