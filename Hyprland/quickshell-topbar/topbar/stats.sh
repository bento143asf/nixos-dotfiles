#!/usr/bin/env bash
set -u

# Short two-sample CPU measurement and RAM usage from /proc.
read -r -a first < /proc/stat
sleep 0.18
read -r -a second < /proc/stat

total1=0
total2=0
for value in "${first[@]:1}"; do total1=$((total1 + value)); done
for value in "${second[@]:1}"; do total2=$((total2 + value)); done

idle1=${first[4]:-0}
idle2=${second[4]:-0}
delta=$((total2 - total1))
idle_delta=$((idle2 - idle1))

cpu=0
if (( delta > 0 )); then
    cpu=$(( 100 * (delta - idle_delta) / delta ))
fi

mem_total=0
mem_available=0
while read -r key value unit; do
    case "$key" in
        MemTotal:) mem_total=$value ;;
        MemAvailable:) mem_available=$value ;;
    esac
done < /proc/meminfo

ram_gb=$(awk -v used="$((mem_total - mem_available))" 'BEGIN { printf "%.1f", used / 1048576 }')

echo "${ram_gb}|${cpu}"
