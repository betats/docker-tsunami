#!/bin/sh
DATEPREFIX=$(date "+%Y%m%d%H/")
mkdir -p logs/$DATEPREFIX

for i in $(cat list_ipv4.txt);
do
  nmap -sL -n -4 $i | awk '/Nmap scan report/{print $NF}' | tr -d "()" | while read l ;
  do
    java -cp tsunami.jar:plugins/* -Dtsunami-config.location=tsunami.yaml com.google.tsunami.main.cli.TsunamiCli --ip-v4-target=$l --scan-results-local-output-format=JSON --scan-results-local-output-filename=logs/$DATEPREFIX/$l.tsunami-output.json
  done
done

for i in $(cat list_ipv6.txt);
do
  nmap -sL -n -6 $i | awk '/Nmap scan report/{print $NF}' | tr -d "()" | while read l ;
  do
    java -cp tsunami.jar:plugins/* -Dtsunami-config.location=tsunami.yaml com.google.tsunami.main.cli.TsunamiCli --ip-v6-target=$l --scan-results-local-output-format=JSON --scan-results-local-output-filename=logs/$DATEPREFIX/$l.tsunami-output.json
  done
done
