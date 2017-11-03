<?php
function cmdPrint($value){
    print(json_encode($value, JSON_PRETTY_PRINT) . "\r\n");
}
$files = glob('*.log');
//echo json_encode($files, JSON_PRETTY_PRINT);
$lineRegex = '/(?P<type>\d)\s+(?P<time>\d+:\d+:\d+\.\d+)\s+(?P<description>.+)(?P<symbol>\w{6}),(?P<frame>\w+)(\s{0,1}\D)*: (?P<details>.*)/';
$spreadAtributtes = '/Spread trade = (?P<current>\d+\.+\d+).+(?P<limit>\d+\.*\d+)/';
$logs = [];
@unlink('concentrado.csv');
@unlink('spreads.csv');
$logFile = fopen('concentrado.csv', 'w');
fputcsv($logFile, [
    "week",
    "day",
    "time",
    "type",
    "symbol",
    "frame",
    "description",
    "details",
]);
$spreadFile = fopen('spreads.csv', 'w');
fputcsv($spreadFile, [
    "week",
    "day",
    "time",
    "type",
    "symbol",
    "frame",
    "description",
    "details",
    "spread",
    "limit",
]);
foreach($files as $file){
    $fileContent = file($file);
    foreach($fileContent as $fileLine){
        preg_match($lineRegex, $fileLine, $line);
        $date = strtotime(basename($file, '.log'));
        $object = [
            "week"=>date('Y\WW', $date),
            "day"=>date('w', $date),
            "time"=>trim($line["time"]),
            "type"=>trim($line["type"]),
            "symbol"=>trim($line["symbol"]),
            "frame"=>trim($line["frame"]),
            "description"=>trim($line["description"]),
            "details"=>trim($line["details"]),
        ];
        fputcsv($logFile, $object);
        if(preg_match($spreadAtributtes, $fileLine, $line)){
            $object['spread'] = intval($line['current']);
            $object['limit'] = $line['limit'];
            fputcsv($spreadFile, $object);
        }
    }
}
fclose($logFile);
fclose($spreadFile);
