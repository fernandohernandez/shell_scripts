#!/bin/bash
#
# Download files from S3, optimize images and upload
# @author Fernando Hernandez <fernandoh.arg@gmail.com>
#
EXPECTED_ARGS=3
E_BADARGS=65
LOCAL_PATH=''
REMOTE_PATH=''
BUCKET_NAME=''

usage()
{
cat << EOF

******************************************************************************************************
*  Usage: `basename $0` options -l local_path -r remote_path [-b bucket_name]                           *
*  Example: `basename $0` -l /home/myuser/works/site/theme/ -r /uploads/files/images/ -b my_bucket      *
******************************************************************************************************

OPTIONS (Flags):
   -h   Show this message
   -c   Clean amazon credentials (S3 key and secret key) 

EOF
}

if [ -f .amz_key ]; then
   key=`cat .amz_key`;
else
   echo "Type Amazon Key: ";
   read key;
   echo -n $key > .amz_key;   
   chmod 600 .amz_key;
   cp ./.amz_key ./download_files_s3/.amz_key;
   cp ./.amz_key ./optimize_images/.amz_key;
   cp ./.amz_key ./upload_cdn/.amz_key;
fi

if [ -f .secret_key ]; then
   secret=`cat .secret_key`;
else
   echo "Type Secret Key: ";
   read secret;
   echo -n $secret > .secret_key;
   chmod 600 .secret_key;
   cp ./.secret_key ./download_files_s3/.secret_key;
   cp ./.secret_key ./optimize_images/.secret_key;
   cp ./.secret_key ./upload_cdn/.secret_key;
fi

while getopts "ch:l:r:b:" OPTION
do
   case $OPTION in
         h )
             usage
             exit 1
             ;;     
         c ) 
             rm .secret_key .amz_key .bucket
             echo "Clean all keys."
             exit 0;
             ;; 
         l ) 
             LOCAL_PATH=$OPTARG            
             ;;
         r ) 
             REMOTE_PATH=$OPTARG  
             ;;
         b ) 
             BUCKET_NAME=$OPTARG 
             ;; 
         ?)
            usage
            exit
            ;;              
     esac
done

if [ $# -lt $EXPECTED_ARGS ]
then
  usage
  exit $E_BADARGS;
fi

echo -n $BUCKET_NAME > .bucket;      
chmod 600 .bucket; 
cp ./.bucket ./download_files_s3/.bucket;
cp ./.bucket ./optimize_images/.bucket;
cp ./.bucket ./upload_cdn/.bucket;

echo "";
echo "1- Download Files to $LOCAL_PATH/original";
cd download_files_s3;
./download.sh -l $LOCAL_PATH/original -r $REMOTE_PATH -b $BUCKET_NAME;
cd ..;
echo "2- Backup files to $LOCAL_PATH/backup";
mkdir $LOCAL_PATH/backup;
cp -r $LOCAL_PATH/original/ $LOCAL_PATH/backup/;
echo "3- Optimize images in $LOCAL_PATH/original";
cd optimize_images;
./optimize.sh $LOCAL_PATH/original;
cd ..;
echo "4- Upload optimized images to S3";
cd upload_cdn;
./upload_cdn.sh $LOCAL_PATH/original/$REMOTE_PATH $LOCAL_PATH/original/;
cd ..;
echo "";
echo "Done!";
exit 0;
