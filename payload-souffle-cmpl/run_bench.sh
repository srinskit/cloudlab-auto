#!/bin/bash

# Exit script on error
set -e

DATA=/data/input/souffle
build_workers=$(nproc)
exe=souffle_cmpl
prev_dl=""

source bench_targets.sh

for target in "${targets[@]}"; do
	read -r dl dd ds <<<"$target"

	# Build program
	if [ "$prev_dl" != "$dl" ]; then
		souffle -o $exe "$dl".dl -j $build_workers
		prev_dl="$dl"
	fi

	for w in "${workers[@]}"; do
		killall $exe || true
		echo "[run_bench] program: $dl, dataset: $dd/$ds, workers: $w"
		cmd="./$exe -F $DATA/$dd/$ds -D . -j $w"
		dlbench run "$cmd" "$dl"_"$ds"_"$w"_souffle-cmpl
	done
done
