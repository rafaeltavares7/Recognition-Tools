#!/bin/bash

echo -e "\n\033[0;32m                  _________-----_____ \033[0m"
echo -e "\033[0;32m       _____------           __      ----_\033[0m"
echo -e "\033[0;32m___----             ___------              \ \033[0m"
echo -e "\033[0;32m   ----________        ----                 \ \033[0m"
echo -e "\033[0;32m               -----__    |             _____)\033[0m"
echo -e "\033[0;32m                    __-                /     \ \033[0m"
echo -e "\033[0;32m        _______-----    ___--          \    /)\ \033[0m"
echo -e "\033[0;32m  ------_______      ---____            \__/  / \033[0m"
echo -e "\033[0;32m               -----__    \ --    _          /\ \033[0m"
echo -e "\033[0;32m                      --__--__     \_____/   \_/\ \033[0m"
echo -e "\033[0;32m --------------------------------|   /          |\033[0m"
echo -e "\033[0;32m                                 |  |___________|\033[0m"
echo -e "\033[0;32m ---------------------------     |  | ((_(_)| )_)\033[0m"
echo -e "\033[0;32m                                 |  \_((_(_)|/(_)\033[0m"
echo -e "\033[0;32m                                 \             (\033[0m"
echo -e "\033[0;32m                                  \ enum.sh V.1.2 \033[0m\n"



alvo="$2"
wordlist="$3"

if [ "$1" == "---dir" ]; then
  cat "$wordlist" | xargs -I {} -P 50 bash -c "brute=\$(curl --max-time 1 --retry 2 -A 'Mozilla/5.0 (X11; Linux x86_64; rv:112.0) Gecko/20100101 Firefox/112.0 (pt-BR)' -o /dev/null -s -w '%{http_code}\n' --header 'Connection: keep-alive' '${alvo}{}');
     if [ \"\$brute\" == \"403\" ]; then
       echo -e '\e[31m[403] ${alvo}{} - Permission Refused\e[0m';
     elif [ \"\$brute\" == \"200\" ]; then
       echo -e '\033[0;32m[200] ${alvo}{} - OK\033[0m';
     elif [ \"\$brute\" == \"301\" ] || [ \"\$brute\" == \"302\" ]; then
       echo -e '\e[33m[301/2] ${alvo}{} - Redirected\e[0m';
       echo \"${alvo}{}\" >> result.txt;
     fi"

  # enumeração, começa a segunda parte, processando result.txt
  if [ -f result.txt ]; then
    cat result.txt | xargs -I {} -P 50 bash -c "
      url='{}';
      for dir in \$(cat "$wordlist"); do
        full_url=\"\${url}/\${dir}\"; # Monta a URL completa com o diretório da wordlist
        brute=\$(curl --max-time 1 --retry 2 -A 'Mozilla/5.0 (X11; Linux x86_64; rv:112.0) Gecko/20100101 Firefox/112.0 (pt-BR)' -o /dev/null -s -w '%{http_code}\n' --header 'Connection: keep-alive' \"\$full_url\");

        if [ \"\$brute\" == \"200\" ]; then
          echo -e \"\033[0;32m[200] \$full_url - OK\033[0m\"
        # Se o código for 301 ou 302, salva no arquivo result.txt
        elif [ \"\$brute\" == \"301\" ] || [ \"\$brute\" == \"302\" ]; then
          echo -e \"\e[33m[301/2] \$full_url - Redirected\e[0m\";
          echo \"\$full_url\" >> result.txt

          # Nova enumeração caso encontre 301 ou 302
          for new_dir in \$(cat "$wordlist"); do
            new_url=\"\${full_url}/\${new_dir}\"
            new_brute=\$(curl --max-time 1 --retry 2 -A 'Mozilla/5.0 (X11; Linux x86_64; rv:112.0) Gecko/20100101 Firefox/112.0 (pt-BR)' -o /dev/null -s -w '%{http_code}\n' --header 'Connection: keep-alive' \"\$new_url\");
            if [ \"\$new_brute\" == \"403\" ]; then
              echo -e \"\e[31m[403] \$new_url - Permission Refused\e[0m\"
            elif [ \"\$new_brute\" == \"200\" ]; then
              echo -e \"\033[0;32m[200] \$new_url - OK\033[0m\"
            fi
          done
        fi
      done"
  fi
  rm result.txt

elif [ "$1" == "---sbd" ]; then
  cat "$wordlist" | xargs -I {} -P 50 bash -c '
    subdomain='{}.$alvo'
    result=$(timeout 1 host "$subdomain" 2>/dev/null | grep "has address" | sed "s/ has address.*//" | uniq)
    if [ -n "$result" ]; then
      echo -e "\033[0;32m[SUBD] $result\033[0m"
    fi
  '

elif [ "$1" == "---cname" ]; then
  cat "$wordlist" | xargs -I {} -P 50 bash -c "
    subdomain=\"{}.$alvo\"
    host=\$(timeout 1 host -t CNAME \"\$subdomain\" 2>/dev/null | grep 'alias' | cut -d' ' -f1,6)
    if [ -n \"\$host\" ]; then
      echo -e \"\033[0;32m[CNAME] \$host\033[0m\"
    fi
  "

elif [ "$1" == "---reverse-dns" ]; then
  for p in $(seq 1 255); do # seq sinaliza uma sequencia de 1 a 255
     result=$(host "$alvo.$p" 2>&1 | grep -i "domain name pointer" | sed 's/domain name pointer//')
     if [ -n "$result" ]; then
       echo -e "\033[0;32m[DNS] $result\033[0m"
     fi
  done

elif [ "$1" == "-h" ]; then
  echo -e "\033[0;32mDirectory: enum.sh ---dir URL [WORDLIST]\033[0m"
  echo -e "\033[0;32mSubdomain: enum.sh ---sbd [DOMAIN.COM] [WORDLIST]\033[0m"
  echo -e "\033[0;32mCheck CNAME: enum.sh ---cname [DOMAIN.COM] [WORDLIST]\033[0m"
  echo -e "\033[0;32mReverse DNS: enum.sh ---reverse-dns [IP: 10.0.0]\033[0m\n"
fi
