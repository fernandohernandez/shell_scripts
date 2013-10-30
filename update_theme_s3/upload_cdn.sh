#!/bin/bash
#
# Upload all files with (extensions) on Path and put to Amazon S3
# @author Fernando Hernandez <fernandoh.arg@gmail.com>
#

EXPECTED_ARGS=2
E_BADARGS=65
base_path_s3="";

if [[ $3 == "--only_scripts" ]]
then
 extensions=( "*.css" "*.js" "*.css.min.gz" "*.js.min.gz");
else
 extensions=( "*.jpg" "*.png" "*.gif" "*.css" "*.css.min.gz" "*.js" "*.js.min.gz");
fi

updated=();
found=();
new=();
upload=();
path=".";
NOW=$(date +"%Y-%m-%d %H:%M");

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

if [ $# -lt $EXPECTED_ARGS ]
then  
  echo "Usage: `basename $0` {local_path} {local_path_remove_before_upload}";
  exit $E_BADARGS
fi

exec &> >(tee -a upload_cdn.log)
echo "[$NOW]----------------------------------------------------------->";

path=`echo $1`;
remove_path=`echo $2`;

(( i=0 ));
for extension in "${extensions[@]}"; do
  (( found[i]=0 )); 
  (( updated[i]=0 ));
  (( new[i]=0 ));
  echo "-> Search ${extension} files on ${path} and compare with remote S3 files.";
  IFS=$'\n';
  files=$(find ${path} -type f -iname "${extension}");
  for file in $files  
  do
    remote_item=${file#$remove_path};

    status=`php s3info.php --accesskey=$key --secretkey=$secret --bucket=$bucket --file="$file" --remote=$base_path_s3$remote_item  2> /dev/null`;
    
    case $status in
     0) #file exits and equals hash, nothing to do   
       echo -ne ".";
       ;;
     1) #new file
       echo "  new file found: $file";
       (( new[$i]++ ));      
       upload+=("$file");
       ;;
     2) #updated        
       echo "  file updated: $file";
       (( updated[$i]++ ));
       upload+=("$file");
       ;;
    esac
        
    (( found[$i]++ ));

  done
  (( i++ ));
done

echo "";
echo "Complete: ";

(( i=0 ));
sum=0;
for extension in "${extensions[@]}"; do
  (( total=updated[i] + new[i] ));
  if [[ $total -gt 0 ]]; then
      echo "         ${extension}: ${new[i]} new files, ${updated[i]} updated, on ${found[i]} files found.";
      (( sum=sum + $total));
  fi  
  (( i++ ));
done

if [[ $4 == "--simulate" ]]
then
 echo "";
 echo "Cancel upload files (only show changes).";
else
 echo "";
 if [[ ${#upload[@]} -gt 0 ]]; then
  echo "-> Uploading files to Amazon S3: ";
  else
  echo " All files are up to date.";
 fi

 count=1;
 for item in ${upload[@]}
 do
  remote_item=${item#$remove_path};
  echo "  * Upload [$count/$sum]: $item -> S3:/$base_path_s3$remote_item ...";
  (( count++ ));
  php s3put.php --accesskey=$key --secretkey=$secret --bucket=$bucket --file="$item" --remote=$base_path_s3$remote_item 2> /dev/null;
 done

 if [[ ${#upload[@]} -gt 0 ]]; then
   echo "";
   echo "Upload complete.";
 fi
fi

exit 0;