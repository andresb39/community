<#
    .Create: 11/02/2020
    .Autor:  Jesus Bergano
    .Version: 1.0
    Backup/Restore Database
#>

### Variables ###

$datetime = get-date -format "MMM.dd.yyyy-HH.m.ss"
$pathlocal = "path to Backup"
$pathlog = "$pathlocal\logs\log_$datetime.log"
$script_sp_backup = @'
	BACKUP DATABASE [Database] TO  DISK = N'D:\pathtobackup\nombre.bak' WITH NOFORMAT, NOINIT, COPY_ONLY,  NAME = N'xxxxx-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
	GO
'@
$script_sp_restore = @'
	USE [master]
	ALTER DATABASE [Database_to_restore] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	RESTORE DATABASE [Database_to_restore] FROM  DISK = N'D:\pathtobackup\nombre.bak' WITH  FILE = 1,  MOVE N'DatabaseFile' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Database_to_restore.mdf',  MOVE N'DatabaseFile_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\PotigianP_QA_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5
	ALTER DATABASE [Database_to_restore] SET MULTI_USER
	GO
'@


### Backup DATABASE Database ###
try {
    echo "Start execution Backup Database --- $datetime" | out-file $pathlog
    Invoke-SqlCmd -ServerInstance localhost -Query $script_sp_backup -QueryTimeout 0 -Verbose *>> $pathlog
    echo "Finish execution Backup Database --- $datetime" | out-file $pathlog -append
}
catch {
    echo "" | out-file $pathlog -append
    echo "Backup Failed " | out-file $pathlog -append
    echo "$_.Exception.Message" | out-file $pathlog -append    
}

### RESTORE Database Database on Database_to_restore ###

try {
    echo "" | out-file $pathlog -append
    echo "Start execution Restore Database_to_restore ---  $datetime" | out-file $pathlog -append
    Invoke-SqlCmd -ServerInstance localhost -Query $script_sp_restore -QueryTimeout 0 -Verbose *>> $pathlog
    echo "Finish execution Restore Database_to_restore --- $datetime" | out-file $pathlog -append
}
catch {
    echo "" | out-file $pathlog -append
    echo "Restore Failed " | out-file $pathlog -append
    echo "$_.Exception.Message" | out-file $pathlog -append    
}

### Remove Backup File ### 
try {
    echo "" | out-file $pathlog -append
    echo "Start delete Backup Backup File ---  $datetime" | out-file $pathlog -append
    Remove-Item $pathlocal\BackupFile.bak -Verbose  *>> $pathlog 
    echo "Finish delete Backup Backup File --- $datetime" | out-file $pathlog -append
}
catch {
    echo "" | out-file $pathlog -append
    echo "delete Failed " | out-file $pathlog -append
    echo "$_.Exception.Message" | out-file $pathlog -append    
}
