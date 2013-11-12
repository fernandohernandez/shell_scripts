<?php

/*
 * Funciones utilizando la API de Amazon S3
 * @author Fernando Hernandez <fernandoh.arg@gmail.com> 
 */

require_once("aws.phar");

use Aws\S3\S3Client;
use Aws\Common\Aws;
use Aws\Common\Enum\Region;
use Guzzle\Http\EntityBody;
use Aws\DynamoDb\Exception\DynamoDbException;

function getArgs($args) {
 $out = array();
 $last_arg = null;
    for($i = 1, $il = sizeof($args); $i < $il; $i++) {
        if( (bool)preg_match("/^--(.+)/", $args[$i], $match) ) {
         $parts = explode("=", $match[1]);
         $key = preg_replace("/[^a-z0-9]+/", "", $parts[0]);
            if(isset($parts[1])) {
             $out[$key] = $parts[1];   
            }
            else {
             $out[$key] = true;   
            }
         $last_arg = $key;
        }
        else if( (bool)preg_match("/^-([a-zA-Z0-9]+)/", $args[$i], $match) ) {
            for( $j = 0, $jl = strlen($match[1]); $j < $jl; $j++ ) {
             $key = $match[1]{$j};
             $out[$key] = true;
            }
         $last_arg = $key;
        }
        else if($last_arg !== null) {
         $out[$last_arg] = $args[$i];
        }
    }
 return $out;
}

function s3_amazon_connect() {
    
    $aws_config = array(
                'key' => S3_AMAZON_KEY,
                'secret' => S3_AMAZON_SECRET
    );

    return S3Client::factory($aws_config);
}

function s3_amazon_fileExists($remotepath) {
    $s3 = s3_amazon_connect();
    
    return $s3->doesObjectExist(S3_AMAZON_BUCKET,$remotepath);     
}

function s3_amazon_getFile($remotepath) {
    $s3 = s3_amazon_connect();
    
    if($s3->doesObjectExist(S3_AMAZON_BUCKET,$remotepath)){
		//Now grab our file.
		$obj= $s3->getObject(
			array(
				'Bucket' => S3_AMAZON_BUCKET,
				'Key' => $remotepath
			)
			);
		
		$ctype = $obj->get('ContentType');
		//get our file data itself
		return array("type"=>$ctype, "file"=>$obj->get('Body'));		
     }      
  return false;     
}

function s3_amazon_putFile($localpath, $remotepath) {
   $s3 = s3_amazon_connect();

   if(file_exists($localpath)){              
	$obj = array(
                'ACL' => 'public-read',
		'Bucket' => S3_AMAZON_BUCKET,
		'Key'    => $remotepath,
		'Body'   => EntityBody::factory(fopen($localpath, 'r'))
	        );        
	
        return $s3->putObject($obj);        
   }
   
   return false;
}

function s3_remove_all($prefix,$reg_expresion=''){
  $s3 = s3_amazon_connect();
  return $s3->deleteMatchingObjects(S3_AMAZON_BUCKET,$prefix, $reg_expresion);
}

function s3_lists_path($prefix){
  $s3 = s3_amazon_connect();
  $options = array(
    'Bucket' => S3_AMAZON_BUCKET,
    'Prefix' => $prefix,
  );
  return $s3->listObjects($options);
}

function downloadPath($local_path, $prefix){
    $s3 = s3_amazon_connect();
    $s3->downloadBucket($local_path, S3_AMAZON_BUCKET, $prefix);
}
?>
