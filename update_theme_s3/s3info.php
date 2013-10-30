<?php

include(dirname(__FILE__)."/s3common.php");

if(!$info=$s3->getObjectInfo($args["bucket"], $args["remote"])){
  //File not exists on S3
  echo "1"; 
} else {
  if(md5_file($args["file"])==$info["hash"]){
     echo "0";      
  } else {
     echo "2";
  }
  if(isset($args["debug"])){ echo " File: ".$args["file"]." \n"; echo md5_file($args["file"])."==".$info["hash"]; }
} 

die;

?>