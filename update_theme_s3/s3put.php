<?php

include(dirname(__FILE__) . "/s3common.php");
include(dirname(__FILE__) . "/headers.php");

foreach ($headers as $extension => $values) {
    if (endsWith(strtolower(basename($args["file"])), $extension)) {
        $metaHeaders = $values;
    }
}

if(!isset($metaHeaders)){
    $metaHeaders = $headers["default"];
}

if ($args["remote"][0] == '/') {
    $args["remote"] = substr($args["remote"], 1);
}

$args["remote"] = str_replace('//', '/', $args["remote"]);

if ($s3->putObjectFile($args["file"], $args["bucket"], $args["remote"], S3::ACL_PUBLIC_READ, array(), $metaHeaders)) {
    echo "    -> Upload OK: http://" . $args["bucket"] . ".s3.amazonaws.com/" . $args["remote"] . "\n";
    die(0);
} else {
    echo "     **** Upload Fail! on upload: s3://" . $args["bucket"] . $args["remote"] . " - check network or access key and secret passwd **** \n";
    die(1);
}
?>
