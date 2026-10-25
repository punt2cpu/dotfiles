#!/usr/bin/env bash
STATE_FILE="/dev/shm/tmux_telemetry_${USER}"
NOW=$(date +%s)

# 1. System Memory (Used/Total GiB and %)
mem_info=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END {u=t-a; printf "%.1f/%.0fG (%.0f%%)", u/1048576, t/1048576, (u/t)*100}' /proc/meminfo)

# 2. CPU Load Average (1-min) & Usage %
load_avg=$(awk '{print $1}' /proc/loadavg)
read -r cpu_total cpu_idle <<<"$(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8+$9, $5+$6}' /proc/stat)"

# 3. CPU Temperature (Tctl from k10temp)
cpu_temp=""
for h in /sys/class/hwmon/hwmon*; do
  if [[ -f "$h/name" ]] && [[ "$(< "$h/name")" == "k10temp" ]]; then
    if [[ -r "$h/temp1_input" ]]; then
      cpu_temp="$(( $(< "$h/temp1_input") / 1000 ))°C"
      break
    fi
  fi
done

# 4. Network Bytes
read -r rx_now tx_now <<<"$(awk 'NR>2 && $1 !~ /^lo:/ {rx+=$2; tx+=$10} END {print rx, tx}' /proc/net/dev)"

cpu_pct=0
rx_rate=0
tx_rate=0
if [[ -f "$STATE_FILE" ]]; then
  read -r prev_time prev_cpu_total prev_cpu_idle prev_rx prev_tx <"$STATE_FILE"
  dt=$((NOW - prev_time))
  dt_cpu=$((cpu_total - prev_cpu_total))
  if ((dt_cpu > 0)); then
    cpu_pct=$((100 * (dt_cpu - (cpu_idle - prev_cpu_idle)) / dt_cpu))
  fi
  if ((dt > 0)); then
    rx_rate=$(((rx_now - prev_rx) / dt))
    tx_rate=$(((tx_now - prev_tx) / dt))
  fi
fi

echo "$NOW $cpu_total $cpu_idle $rx_now $tx_now" >"$STATE_FILE"

fmt_net() {
  if (($1 >= 1048576)); then
    awk -v b="$1" 'BEGIN {printf "%.1fMB/s", b/1048576}'
  else
    awk -v b="$1" 'BEGIN {printf "%.0fKB/s", b/1024}'
  fi
}

# 5. GPU Telemetry (AMDGPU: Load, Temps, VRAM)
gpu_hwmon=""
for h in /sys/class/hwmon/hwmon*; do
  if [[ -f "$h/name" ]] && [[ "$(< "$h/name")" == "amdgpu" ]]; then
    gpu_hwmon="$h"
    break
  fi
done

gpu_load="0%"
gpu_temp=""
gpu_vram=""

if [[ -n "$gpu_hwmon" ]]; then
  # Utilization
  if [[ -r "${gpu_hwmon}/device/gpu_busy_percent" ]]; then
    gpu_load="$(< "${gpu_hwmon}/device/gpu_busy_percent")%"
  elif [[ -r /sys/class/drm/card0/device/gpu_busy_percent ]]; then
    gpu_load="$(< /sys/class/drm/card0/device/gpu_busy_percent)%"
  fi

  # Temperatures: edge (temp1) & junction (temp2)
  edge=""
  junc=""
  [[ -r "${gpu_hwmon}/temp1_input" ]] && edge="$(( $(< "${gpu_hwmon}/temp1_input") / 1000 ))°C"
  [[ -r "${gpu_hwmon}/temp2_input" ]] && junc="$(( $(< "${gpu_hwmon}/temp2_input") / 1000 ))°C"
  if [[ -n "$edge" && -n "$junc" ]]; then
    gpu_temp="${edge}(${junc})"
  elif [[ -n "$edge" ]]; then
    gpu_temp="${edge}"
  fi

  # VRAM Usage (Bytes converted to GiB)
  dev_dir="${gpu_hwmon}/device"
  if [[ -r "${dev_dir}/mem_info_vram_used" && -r "${dev_dir}/mem_info_vram_total" ]]; then
    v_used=$(< "${dev_dir}/mem_info_vram_used")
    v_tot=$(< "${dev_dir}/mem_info_vram_total")
    gpu_vram=$(awk -v u="$v_used" -v t="$v_tot" 'BEGIN {printf "%.1f/%.0fG", u/1073741824, t/1073741824}')
  fi
fi

# 6. Assemble Output
cpu_str="CPU: ${cpu_pct}%"
[[ -n "$cpu_temp" ]] && cpu_str="${cpu_str} ${cpu_temp}"
cpu_str="${cpu_str} (${load_avg})"

gpu_str="GPU: ${gpu_load}"
[[ -n "$gpu_temp" ]] && gpu_str="${gpu_str} ${gpu_temp}"
[[ -n "$gpu_vram" ]] && gpu_str="${gpu_str} [${gpu_vram}]"

printf "%s | MEM: %s | %s | NET: ↓%s ↑%s" \
  "$cpu_str" \
  "$mem_info" \
  "$gpu_str" \
  "$(fmt_net $rx_rate)" \
  "$(fmt_net $tx_rate)"
