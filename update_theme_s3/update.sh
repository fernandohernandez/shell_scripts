#!/bin/bash
#
# Update theme files on S3:
#   - minify changed css files
#   - gzip changed files css and js
#   - upload all updated files to S3
# @author Fernando Hernandez <fernandoh.arg@gmail.com>
#
EXPECTED_ARGS=3
E_BADARGS=65
ONLY_SCRIPTS=0
UPLOAD=1
LOCAL_PATH=''
EXCLUDE_PATH=''
BUCKET_NAME=''

usage()
{
cat << EOF

******************************************************************************************************
*  Usage: `basename $0` options -l local_path -e exclude_local_subpath_upload [-b bucket_name]           *
*  Example: `basename $0` -s -l /home/myuser/works/site/theme/ -e /home/myuser/works/site/ -b my_bucket  *
*          -> upload to S3://my_bucket/theme/ (only scripts)                                         *
******************************************************************************************************

OPTIONS (Flags):
   -h   Show this message
   -s   Only put scripts *.css, *.js, etc. (no images)
   -n   No upload files (simulate)
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

while getopts "csnh:l:e:b:" OPTION
do
   case $OPTION in
         h )
             usage
             exit 1
             ;;
         s )
             ONLY_SCRIPTS=1                                     
             ;; 
         n )
             UPLOAD=0             
             ;;        
         c ) 
             rm .secret_key .amz_key .bucket
             echo "Clean all keys."
             exit 0;
             ;; 
         l ) 
             LOCAL_PATH=$OPTARG            
             ;;
         e ) 
             EXCLUDE_PATH=$OPTARG  
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
echo "Exclude Path: $EXCLUDE_PATH"
echo "Remote: S3://$BUCKET_NAME/${LOCAL_PATH#$EXCLUDE_PATH}"

##
# STEP 1: minify css
##
echo "";
echo "      [*********** STEP 1: Minify CSS & JS files ***************************]";
echo "";
./minify_cdn.sh $LOCAL_PATH $EXCLUDE_PATH;

##
# STEP 2: gzip css and js
##
echo "";
echo "      [*********** STEP 2: Gzip changed CSS and JS files **************]";
echo "";
./gzip_cdn.sh $LOCAL_PATH $EXCLUDE_PATH;

##
# STEP 3: uploads udpated files (jpg,png,gif,css,js,css.min.gz,js.gz) to S3
##
echo "";
echo "      [*********** STEP 3: Upload updated files to S3 *****************]";
EXTRA_OPTIONS=''
if [ $ONLY_SCRIPTS -eq 1 ] 
then
  echo "Upload only scripts (css, js, css.min.gz, js.min.gz)";
  EXTRA_OPTIONS="--only_scripts";
fi 

if [ $UPLOAD -eq 0 ] 
then
  echo "Only check changes (no upload files to s3)";
  EXTRA_OPTIONS="$EXTRA_OPTIONS --simulate";
fi 
  ./upload_cdn.sh $LOCAL_PATH $EXCLUDE_PATH $EXTRA_OPTIONS;

echo "";
echo "      [**************************** END *******************************]";
echo "";
exit 0;
