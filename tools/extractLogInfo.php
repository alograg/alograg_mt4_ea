<?php
passthru('xcopy C:\Users\Henry\AppData\Roaming\MetaQuotes\Terminal\C000232C5F64AA0BDA95D52B828AF160\logs\hosting.5873405.experts\*.log D:\Personal\GDrive\hosting.5873405.experts\*.* /Y/C');
passthru('del /Q C:\Users\Henry\AppData\Roaming\MetaQuotes\Terminal\C000232C5F64AA0BDA95D52B828AF160\logs\hosting.5873405.experts\*.log');
chdir('D:\Personal\GDrive\hosting.5873405.experts');
/**
 * Salida de comandos
 * 
 * @param string $value El valir para mostrar
 * 
 * @return void
 */
function cmdPrint($value)
{
    print(json_encode($value, JSON_PRETTY_PRINT) . "\r\n");
}
$files = glob('*.log');
//echo json_encode($files, JSON_PRETTY_PRINT);
$lineRegex = '/(?P<type>\d)\s+(?P<time>\d+:\d+:\d+\.\d+)\s+(?P<description>.+)(?P<symbol>\w{6}),(?P<frame>\w+)(\s{0,1}\D)*: (?P<details>.*)/';
$spreadAtributtes = '/Spread trade = (?P<current>\d+\.+\d+)\D+(?P<limit>\d+\.*\d+)/';
$logs = [];
@unlink('concentrado.csv');
@unlink('spreads.csv');
@unlink('spreads.sqlite');
$logFile = fopen('concentrado.csv', 'w');
fputcsv(
    $logFile,
    [
        "week",
        "day",
        "time",
        "type",
        "symbol",
        "frame",
        "description",
        "details",
    ]
);
$spreadFile = fopen('spreads.csv', 'w');
fputcsv(
    $spreadFile,
    [
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
    ]
);
$dir = 'sqlite:spreads.sqlite';
$pdo  = new PDO($dir) or die("cannot open the database");
$pdo->beginTransaction();
$pdo->exec("DROP IF EXIST spreads");
$slqCreate = <<<SQL
CREATE TABLE IF NOT EXISTS spreads (
    week TEXT,
    day INTEGER,
    'time' TEXT,
    'type' INTEGER,
    symbol TEXT,
    frame TEXT,
    'description' TEXT,
    details TEXT,
    spread NUMERIC default 0,
    current_limit NUMERIC default 0
);
SQL;
$fields = [
    "week",
    "day",
    "time",
    "type",
    "symbol",
    "frame",
    "description",
    "details",
    "spread",
    "current_limit",
];
$pdo->exec($slqCreate);
$insert_fields_str = implode(', ', $fields);
$insert_values_str = implode(', ', array_fill(0, count($fields),  '?'));
$insert_sql = "INSERT INTO spreads ($insert_fields_str) VALUES ($insert_values_str)";
$pdoInsert = $pdo->prepare($insert_sql);
if (!$pdoInsert) {
    cmdPrint("PDO::errorInfo():");
    print_r($pdo->errorInfo());
    die('no pudo preparar');
}
$lastInitialization = null;
foreach ($files as $file) {
    $fileContent = file($file);
    foreach ($fileContent as $fileLine) {
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
        if ('initialized' == $object['details']) {
            $lastInitialization = max($object['week'], $lastInitialization);
        }
        fputcsv($logFile, $object);
        if (preg_match($spreadAtributtes, $fileLine, $line)) {
            $object['spread'] = intval($line['current']);
            $object['current_limit'] = $line['limit'];
            fputcsv($spreadFile, $object);
            if (!$pdoInsert->execute(array_values($object))) {
                cmdPrint("PDOStatement::errorInfo():");
                print_r($object);
                print_r($insert_sql);
                print_r($pdoInsert->errorInfo());
                die('no pudo insertar');
            }
        }
    }
}
fclose($logFile);
fclose($spreadFile);
$pdo->commit();
$evaluation = <<<SQL
SELECT
  s1.symbol,
  max(s1.spread)           AS maxSpread,
  min(s1.spread)           AS minSpread,
  median(s1.spread)        AS mediaSpread,
  AVG(s1.spread)           AS avgSpread
FROM spreads s1
  WHERE week >= '$lastInitialization'
GROUP BY s1.symbol;
SQL;
print $evaluation;
die();
//$pdo->query("SELECT load_extension('libextensionfunctions.dll');");
$bd = new SQLite3('spreads.sqlite');
//$bd->loadExtension('libextensionfunctions.dll');
$analisis = $bd->prepare($evaluation);
if (!$analisis) {
    cmdPrint("PDO::errorInfo():");
    print_r($pdo->errorInfo());
    die('no pudo analizar');
}
if (!$analisis->execute()) {
    cmdPrint("PDOStatement::errorInfo():");
    print_r($analisis->errorInfo());
    die('no pudo consultar');
}
$resultado = $analisis->fetchAll();
cmdPrint($resultado);
