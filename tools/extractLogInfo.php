<?php
function cmdPrint($value){
    print(json_encode($value, JSON_PRETTY_PRINT) . "\r\n");
}
$files = glob('*.log');
//echo json_encode($files, JSON_PRETTY_PRINT);
$lineRegex = '/(?P<type>\d)\s+(?P<time>\d+:\d+:\d+\.\d+)\s+(?P<description>.+)(?P<symbol>\w{6}),(?P<frame>\w+)(\s{0,1}\D)*: (?P<details>.*)/';
$logs = [];
$fp = fopen('concentrado.csv', 'w');
fputcsv($fp, [
    "type",
    "time",
    "description",
    "symbol",
    "frame",
    "details",
    "day",
]);
foreach($files as $file){
    $fileContent = file($file);
    foreach($fileContent as $fileLine){
        preg_match($lineRegex, $fileLine, $line);
        $object = [
            "type"=>trim($line["type"]),
            "time"=>trim($line["time"]),
            "description"=>trim($line["description"]),
            "symbol"=>trim($line["symbol"]),
            "frame"=>trim($line["frame"]),
            "details"=>trim($line["details"]),
            "day"=>basename($file, '.log'),
        ];
        fputcsv($fp, $object);
    }
}
fclose($fp);
