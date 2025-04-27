#!/bin/bash

echo -e "\n\033[0;32m                     █████████████████▓  \033[0m"
echo -e "\033[0;32m                ▒██▓                   ▒███░  \033[0m"
echo -e "\033[0;32m             ███        ▓▓████████▒       ░ █▓█  \033[0m"
echo -e "\033[0;32m          ███  ▒ ▓ ████▒▒▓▒▒▒▓▓  ▒█▓▓████   ▓  ███  \033[0m"
echo -e "\033[0;32m        ████ ▒ █ ██░ ▓ ▓░▒▒▒░   ▒  ▓ ░▒░█ ░██░▓ █  ██▒  \033[0m"
echo -e "\033[0;32m     ██▒ ░ █░█▓░░░ █▓░▓░▓▒ ██████ ▒▒▒▓ ▒▓  ░░▒█░█ █ ███  \033[0m"
echo -e "\033[0;32m   ▓██   █ ██   ░░░ ▓░  ▒▒ ██▒ ▒ ██ ▒▒ ░░▒ ░░░   ▓█ ▓ █ ██  \033[0m"
echo -e "\033[0;32m █▓  ░ ▓█      ░ ░ ▓▒░ ▒▒ ██ ██ ██ ▒▓  ▒█ ░ ░      ██ ░ ███  \033[0m"
echo -e "\033[0;32m█▓  █  ██           █ ░ ░░  ████  ░▒ ░ ▓    ░      █▒  █  ██  \033[0m"
echo -e "\033[0;32m ████▓░█ ░▓█▒       ▒▓  ░▒░░    ░▒▓░ ▒█░       █▓█▒ █░████  \033[0m"
echo -e "\033[0;32m        ▒███▒█ ███    ▓▓░ ░ ░░▒     ▒▒    █▒█ █▓███  \033[0m"
echo -e "\033[0;32m             ██▓░  ▓███ ▓▒      ░░▒░ ███░  ▒██▒  \033[0m"
echo -e "\033[0;32m                 ███    ░▒██████▓█░    ░███  \033[0m"
echo -e "\033[0;32m                    █████▒▒▒▒▒▒▒▒▒▒████▒  \033[0m"
echo -e "\033[0;32mV 1.0\033[0m"
echo -e "\033[0;32mlinktr.ee/rafael_tavares.7/ \033[0m\n"

# Função para capturar a interrupção (Ctrl+C) e matar todos os pings
trap "kill 0" SIGINT
host=$2

if [ "$1" == "---scan" ]; then
  tor=$(service tor -h)
  if [ -z "$tor" ]; then
    apt install tor -y
  fi
  service tor start
  cat "top_portas.txt" | xargs -I {} -P 50 bash -c "
    result=\$(proxychains nc -zv -w 5 \"$host\" {} 2>&1 | grep -i 'open' | sed 's/: Operation now in progress//g; s/\[[^]]*\]//g; s/open//g') # -w especifica o tempo limite
    if [ -n \"\$result\" ]; then
      echo -e \"\033[0;32m[OPEN] \$result\033[0m\"
    fi
  "
  service tor stop

elif [ "$1" == "---network-scan" ]; then
  for p in $(seq 1 255); do
     result=$(ping -c 1 -W 1 "$ip$p" | grep "64 bytes" | cut -d " " -f 4 | tr -d ":")
     if [ -n "$result" ]; then
       echo -e "\033[0;32m[IP] $result\033[0m"
     fi &
     sleep 1

     # cut -d " " -f 4: cut seleciona o 4º campo
     # tr -d ":": Remove os dois pontos (:) da string
     # & no final significa que cada ping será executado em segundo plano
  done

elif [ "$1" == "-h" ]; then
  echo -e "\033[0;32mScan: portscan.sh ---scan [HOST]\033[0m"
  echo -e "\033[0;32mNetwork scan: portscan.sh ---network-scan [IP exemplo: 10.0.0.]\033[0m\n"
fi
