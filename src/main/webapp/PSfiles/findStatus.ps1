param($p1, $p2, $p3, $p4, $p5, $p6, $modulePath, $outputFilePath)
Import-Module -Force $modulePath
Get-ResultsFromAPIs  $p1 $p2 $p3 $p4 $p5 $p6 $outputFilePath
#Get-WorkItem 1179 -verbose