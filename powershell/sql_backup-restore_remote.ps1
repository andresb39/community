<#
    .Create: 11/02/2020
    .Autor:  Jesus Bergano
    .Version: 2.0
	.Modificado: 08/03/2020
    Backup Database and restore to remote server
#>

<# Variables #>
$datetime = get-date -format "dd.MMMM.yyyy-HH.m.ss"
$pathlocal = "LocalPath"
$pathlog = "$pathlocal\logs\log_$datetime.log"
$pathremote = "\\xxxxxx\Backup" #Folder remote 
$sqllocal = "192.168.x.x" # SQL Server to BACKUP
$sqlremote =  "192.168.x.x" # SQL Server to RESTORE
$dbname = "LocalDB" # Database to BACKUP
$backupPath= "$pathlocal\BackupFile.bak" #Set the backup file path
$script_sp_restore = @'
USE [master]
ALTER DATABASE [Database_to_restore] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [Database_to_restore] FROM  DISK = N'D:\xxxxx\BackupFile.bak' WITH  FILE = 1,  MOVE N'Database_Files' TO N'D:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Database_to_restore.mdf',  MOVE N'DatabaseFile_log' TO N'D:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\PotigianP_QA_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [Database_to_restore] SET MULTI_USER
GO
'@

<#Backup DB PotigianP#>
Write-Output "Start Execution Backup Full --- $datetime" | out-file $pathlog
Invoke-SqlCmd -ServerInstance $sqllocal -Query "BACKUP DATABASE [$dbname] TO DISK = N'$backupPath' WITH NOFORMAT, NOINIT, NAME = N'Backup Full DB', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
GO" -Username sa -Password admin01 -QueryTimeout 0 -ErrorAction Stop -Verbose *>> $pathlog
$datetime = get-date -format "dd.MMMM.yyyy-HH.m.ss"
Write-Output "Finish Execution Backup Full --- $datetime" | out-file $pathlog -append


<#Copy backup File to remote server...#>
if (Test-Path $backupPath) {
	$datetime = get-date -format "dd.MMMM.yyyy-HH.m.ss"
    Write-Output "Start copy Backup file to Remote Server --- $datetime"  | out-file $pathlog -append
    Move-Item -Path $backupPath -Destination $pathremote -Force -ErrorAction Stop -Verbose *>> $pathlog
	$datetime = get-date -format "dd.MMMM.yyyy-HH.m.ss"
    Write-Output "Finish copy Backup file to remote server --- $datetime"  | out-file $pathlog -append
}
else {
    Write-Output "File move failed"  | out-file $pathlog -append
}

<# Ejecucion del Restore#>
$datetime = get-date -format "dd.MMMM.yyyy-HH.m.ss"
Write-Output "Start execution Restore Database_to_restore  --- $datetime" | out-file $pathlog -append
Invoke-SqlCmd -ServerInstance $sqlremote -Query $script_sp_restore -Username sa -Password Admin01 -QueryTimeout 0 -ErrorAction Stop -Verbose *>> $pathlog
$datetime = get-date -format "dd.MMMM.yyyy-HH.m.ss"
Write-Output "Finish execution Restore Database_to_restore --- $datetime" | out-file $pathlog -append
