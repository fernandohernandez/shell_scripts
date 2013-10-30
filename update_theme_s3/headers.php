<?php

//Un mes de expire:
define('DEFAULT_CACHE_EXPIRE','max-age=2592000, public, must-revalidate, proxy-revalidate');
define('YEAR_CACHE_EXPIRE','max-age=31536000, public, must-revalidate, proxy-revalidate');

$headers=array(
   "gif" => array(       
       "Cache-Control" => YEAR_CACHE_EXPIRE,
       "Content-Type" => "image/gif"
    ),  
    "jpg" => array(       
       "Cache-Control" => YEAR_CACHE_EXPIRE,
       "Content-Type" => "image/jpg"
    ),
    "png" => array(       
       "Cache-Control" => YEAR_CACHE_EXPIRE,
       "Content-Type" => "image/png"
    ),
    "js" => array(       
       "Cache-Control" => DEFAULT_CACHE_EXPIRE,
       "Content-Type" => "application/x-javascript"
    ),
    "js.min.gz" => array(       
       "Cache-Control" => DEFAULT_CACHE_EXPIRE,
       "Content-Type" => "application/x-javascript",
       "Content-Encoding" => "gzip"
    ),
    "css" => array(       
       "Cache-Control" => DEFAULT_CACHE_EXPIRE,
       "Content-Type" => "text/css"
    ),
    "css.min.gz" => array(       
       "Cache-Control" => DEFAULT_CACHE_EXPIRE,
       "Content-Type" => "text/css",
       "Content-Encoding" => "gzip"
    ),
     
   "default" => array(
       "Cache-Control" => DEFAULT_CACHE_EXPIRE
   )  
);

?>