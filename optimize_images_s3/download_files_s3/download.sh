#!/bin/bash
#
# Download files from S3:
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
fi

if [ -f .secret_key ]; then
   secret=`cat .secret_key`;
else
   echo "Type Secret Key: ";
   read secret;
   echo -n $secret > .secret_key;
   chmod 600 .secret_key;
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

echo "Local Path: $LOCAL_PATH"
echo "Remote: S3://$BUCKET_NAME$REMOTE_PATH"

echo "";
echo "      [*********** Downloads files *****************]";

php download.php --accesskey=$key --secretkey=$secret --bucket=$BUCKET_NAME --local=$LOCAL_PATH --remote=$REMOTE_PATH;

echo "";
echo "      [****************** END **********************]";
echo "";
exit 0;
