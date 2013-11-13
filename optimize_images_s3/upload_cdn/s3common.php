<?php

require_once(dirname(__FILE__)."/S3.php");
error_reporting(0);

$args = getArgs($_SERVER['argv']);

$s3 = new S3($args["accesskey"], $args["secretkey"]);

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

function endsWith($haystack, $needle)
{
    return $needle === "" || substr($haystack, -strlen($needle)) === $needle;
}

?>
