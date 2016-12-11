#!/bin/bash
set -euo pipefail

digit_to_string() {
  declare digit="$1"
  case "$digit" in
    0) echo -n "zero" ;;
    1) echo -n "one" ;;
    2) echo -n "two" ;;
    3) echo -n "three" ;;
    4) echo -n "four" ;;
    5) echo -n "five" ;;
    6) echo -n "six" ;;
    7) echo -n "seven" ;;
    8) echo -n "eight" ;;
    9) echo -n "nine" ;;
  esac
}

number_to_string() {
  declare number="$1"
  local i digit string=""

  for (( i=0; i<"${#number}"; i++ )); do
    digit="${number:$i:1}"
    [[ $i -ne 0 ]] && string+="-"
    string+="$(digit_to_string "$digit")"
  done

  echo -n "$string"
}

update_server_config() {
  local ip fourth name iface="${CONSUL_BIND_INTERFACE:-eth0}"

  ip="$(ip address show "$iface" | grep 'inet ' | head -n1 | awk '{print $2}' | cut -d/ -f 1)"
  fourth="$(cut -d. -f 4 <<< "$ip")"
  name="$(number_to_string "$fourth")"
  cat > /consul/config/0_swarm.json <<EOF
{
"node_name": "$name",
"bind_addr": "$ip",
"server": true,
"bootstrap_expect": 3
}
EOF
}

update_discovery() {
  local othersString json othersCount=0 first=1
  declare -a others

  while [[ $othersCount -lt 3 ]]; do
    sleep 1
    echo "Trying to find other consul servers..."
    othersString="$(dig tasks.consul +short)"
    readarray -t others <<< "$othersString"
    othersCount="${#others[@]}"
  done

  json="{\"retry_join\": ["
  for addr in "${others[@]}"; do
   [[ $first -eq 1 ]] && first=0 || json+=","
   json+="\"$addr\""
  done
  json+="]}"

  echo "$json" > /consul/config/1_join.json
}

main() {
  [[ ! -f /consul/config/0_swarm.json ]] && update_server_config
  update_discovery

  exec docker-entrypoint.sh "$@"
}

main "$@"
