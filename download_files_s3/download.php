<?php

include("s3_functions.php");

$args = getArgs($_SERVER['argv']);

define('S3_AMAZON_KEY',$args["accesskey"]);
define('S3_AMAZON_SECRET',$args["secretkey"]);
define('S3_AMAZON_BUCKET',$args["bucket"]);

downloadPath($args["local"],$args["remote"]);

?>