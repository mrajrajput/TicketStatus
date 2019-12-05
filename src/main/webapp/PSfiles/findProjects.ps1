param($p1, $p2, $p3, $modulePath, $AzureProjectsFilePath)
Import-Module -Force  $modulePath
Find-Projects  $p1  $p2  $p3  $AzureProjectsFilePath