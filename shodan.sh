#!/bin/bash
#This script aims to export IPs from saved Shodan result pages
#By default, you may want to save Shodan page(s) (e.g:https://www.shodan.io/search?query=IP+camera") 
#to /home/user/Downloads by with Firefox, run this script, and the result should appear in /home/user/shodan-ip
#Export path and Download can be changed by your own
#===================================
func_host_print()
#Sequentially export hosts from filename on each line
{
    if [ $(($line_count)) -le $line_num ] ;then
        line_content=$(cat -n $shodan_path$folder/shodan-file-list |head -n $line_count  | tail -n 1|cut -c 8-)
        host_list=`lynx --dump $shodan_path$folder/$(echo $line_content) |tr "a-zA-Z_" "-"|grep -v - |cut -c 8- `
        echo $host_list | tr " " "\n"
        echo $host_list | tr " " "\n" >> $shodan_path$folder/host_list
        add=`echo $host_list | tr " " "\n" | wc -l`
        host_count=$(( $add + $host_count))
	      #Count number of hosts
          line_count=$(($line_count+1))
          func_host_print
      else
           echo -e "\e[34m[Info]\e[0m"Total $host_count result\(s\)
           echo -e "\e[34m[Info]\e[0m"All in $shodan_path$folder/
         #End of file: count number of ressults
  fi
 }
func_init_host()
#Set initial variables
{
line_num=$(cat $shodan_path$folder/shodan-file-list |wc -l)
line_count=1
host_count=0
func_host_print
}
change_name()
#Replace special characters in file names by _ characters
{
  for file in $down_path*.html ; do
          mv "$file" $shodan_path$folder/"$(sed 's/[^0-9A-Za-z_.]/_/g' <<< "$file")"
#          rm -r $down_path"${$file:0:-2}"
          rm -r $down_path/*Shodan\ Search_files
  done
  }
#######END OF FUNCTIONS##############
shodan_path=/home/user/shodan-ip/
down_path=/home/user/Downloads/
if [ ! -d $shodan_path ] ; then
  mkdir $shodan_path
  echo -e "\e[34m[Info]\e[0m" $shodan_path doesn\'t exist.Creating...
fi

count=`ls -1 $down_path*.html 2>/dev/null | wc -l`
if [ $count = 0 ] ;then
  echo -e "\e[91m[Warning]\e[0m"no .html file in $down_path.Exiting...
  exit 1
fi

for ((fld=1;fld<1000;fld++)) ; do
    if [ ! -d $shodan_path$fld ]  ; then
     folder=$fld
     mkdir $shodan_path$folder
     break
    fi
done


change_name
ls -p $shodan_path$folder | grep -v / |grep Shodan_Search > $shodan_path$folder/shodan-file-list

func_init_host

