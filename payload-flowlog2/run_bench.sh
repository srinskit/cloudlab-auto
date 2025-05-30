#!/bin/bash

# Exit script on error
set -e

SRC=/data
DATA=/data/input
exe=$SRC/FlowLogTest2/target/release/executing

swapoff -a

source targets.sh

for target in "${targets[@]}"; do
	read -r dl dp key charmap threads tout <<<"$target"
	ds=`basename $dp`

	if [ -z "$tout" ]; then
		tout=600s
	fi

	if [[ "$charmap" == *"F2"* ]]; then
		IFS=',' read -ra workers <<<"$threads"
		for w in "${workers[@]}"; do
			echo "[run_bench] program: $dl, dataset: $ds, workers: $w"
			cmd="$exe --program $dl.dl --facts $DATA/$dp --csvs . --workers $w"
			tag="$dl"_"$ds"_"$w"_flowlog
			tag="${tag//\//-}"

			sync && sysctl vm.drop_caches=3

			set +e
			/usr/bin/time -f "LinuxRT: %e" timeout $tout dlbench run "$cmd" "$tag" 2>$tag.info
			ret=$?
			set -e

			# Evaluate result
			if [[ $ret == 0 ]]; then
				echo "Status: CMP" >>$tag.info
			elif [[ $ret == 124 ]]; then
				echo "Status: TOUT" >>$tag.info
			elif [[ $ret == 137 ]]; then
				echo "Status: OOM" >>$tag.info
			else
				echo "Status: DNF" >>$tag.info
			fi

			if [[ "$program" == "cc" ]]; then
			echo hi
				# cnt=$(cat CC1.csv | cut -d "," -f 2 | sort | uniq | wc -l)
				# echo "DLOut: $cnt" >>$tag.info
			else
				sed -n "s/Delta of.*\[$key\]: ((), (), \([0-9]*\))/DLOut: \1/Ip" $tag*.out >>$tag.info
			fi
			echo "DLBenchRT:" $(tail -n 1 $tag*.log | cut -d ',' -f 1) >>$tag.info
		done
	fi
done
