#!/bin/bash
# Common functions
#

IFS=$'\n' read -d '' -r -a exclude_files < exclude_files.txt

exclude(){
 for exclude_file in "${exclude_files[@]}"
 do 
   if [[ $1 = $exclude_file ]]
     then
       echo 1
       exit
   fi  
 done
 echo 0
}

