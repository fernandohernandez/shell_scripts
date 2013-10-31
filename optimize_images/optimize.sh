#!/bin/bash
#
# Optimize JGP and PNG images for web
# @author Fernando Hernandez <fernandoh.arg@gmail.com>
#

EXPECTED_ARGS=1
E_BADARGS=65
extensions=( "png" "jpg" );
updated=();
unchanged=();
path=".";
size_act=0;
new_size=0;

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {images_path}";
  exit $E_BADARGS
fi

path=`echo $1`;

for extension in "${extensions[@]}"; do
  (( updated[i]=0 ));
  echo "";
  echo "-> Search and optimize ${extension} files on ${path}";
  IFS=$'\n';
  files=$(find ${path} -type f -iname *."${extension}");
  for file in $files  
  do
    case ${extension} 
         in
           jpg) 
               size_act=`du $file | awk '{print $1}'`;
               size_act=${size_act#$file};
               jpegtran -optimize -copy none $file > "${file}_out";
               mv "${file}_out" $file;
               new_size=`du $file | awk '{print $1}'`;
               echo "    -$file size before optimize: $size_act (bytes) | now: $new_size (bytes)";
               if [[ $size_act == $new_size ]]
                 then
                  (( unchanged[i]++ ));
                 else
                  (( updated[i]++ ));
               fi
               ;;
           png) 
               size_act=`du -h $file | awk '{print $1}'`;
               size_act=${size_act#$file};
               optipng $file > /dev/null;
               new_size=`du -h $file | awk '{print $1}'`;
               echo "    -$file size before optimize: $size_act (bytes) | now: $new_size (bytes)";
               if [[ $size_act == $new_size ]]
                 then
                  (( unchanged[i]++ ));
                 else
                  (( updated[i]++ ));
               fi
               ;;
    esac
  done
  (( i++ ));
done

i=0;
act=0;
for extension in "${extensions[@]}"; do
  if [[ updated[i] -gt 0 ]]; then
      echo "         ${updated[i]} ${extension} files optimized.";
      (( act++ ));
  fi  
  if [[ unchanged[i] -gt 0 ]]; then
      echo "         ${unchanged[i]} ${extension} files unchanged (already optimized).";
      (( act++ ));
  fi 
  (( i++ ));
done

echo "End image optimization.";

exit 0;