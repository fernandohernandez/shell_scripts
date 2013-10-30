#!/bin/bash
#
# Gzip all files (extensions) on Path and put to Amazon S3
# @author Fernando Hernandez <fernandoh.arg@gmail.com>
#

EXPECTED_ARGS=2
E_BADARGS=65
base_path_s3="";
extensions=( "*.css.min" "*.js.min" );
updated=();
path=".";
NOW=$(date +"%Y-%m-%d %H:%M");

source common.sh

if [ -f .amz_key ]; then
   key=`cat .amz_key`;
else
   echo "Type Amazon Key: ";
   read key;
   echo -n $key > .amz_key;   
   chmod 600 .amz_key;
fi

if [ -f .secret_key ]; then
   secret=`cat .secret_key`;
else
   echo "Type Secret Key: ";
   read secret;
   echo -n $secret > .secret_key;
   chmod 600 .secret_key;
fi

if [ -f .bucket ]; then
   bucket=`cat .bucket`;
else
   echo "Type S3 Bucket name: ";
   read bucket;
   echo -n $bucket > .bucket;      
   chmod 600 .bucket; 
fi

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {local_path} {local_path_remove_before_upload}";
  exit $E_BADARGS
fi

exec &> >(tee -a gzip_cdn.log)
echo "[$NOW]----------------------------------------------------------->";

path=`echo $1`;
remove_path=`echo $2`;

i=0;

for extension in "${extensions[@]}"; do
  (( updated[i]=0 ));
  echo "-> Search and gzip ${extension} files on ${path}";
  IFS=$'\n';
  files=$(find ${path} -type f -iname "${extension}");
  for file in $files  
  do
   remote_item=${file#$remove_path};
   
   #If file not in excludes paths
   if [ $(exclude $remote_item) -eq 0 ]
    then
       #if file.gz not exists or file is newer than file.gz
       if [ $file -nt "$file.gz" ]; then 
         echo "   * Gzip $file";
         gzip -c $file > "$file.gz"; 
         (( updated[i]++ ));
       fi
    fi
  done
  (( i++ ));
done

echo "";
echo "Complete: ";

i=0;
act=0;
for extension in "${extensions[@]}"; do
  if [[ updated[i] -gt 0 ]]; then
      echo "         ${updated[i]} ${extension}.gz files updated.";
      (( act++ ));
  fi  
  (( i++ ));
done

if [[ act -eq 0 ]]; then
  echo "         All files are up to date.";
fi

exit 0;