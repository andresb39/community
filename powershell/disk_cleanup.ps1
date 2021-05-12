<#
	Script: Disk_CleanUp v2
    Autor: Jesus Bergaño
    Tareas a realizar:
    1. Realiza Backup de los Event Logs y limpia los mismos.
    2. Elimina archivos temporales de usuarios
    3. Elimina archivos de la papelera de reciclaje.
    4. Elimina archivos temporales de Windows.
    5. Ejecuta la herramienta Disk CleanUp tool.
 #>

<######################  Variables ######################>

# EventLogs Variables
$eventls = Get-EventLog -List
$date = Get-Date -format "yyyyMMdd"
$path = "D:\backup\"

# Recycle Bin Variables
$objShell = New-Object -ComObject Shell.Application   
$objFolder = $objShell.Namespace(0xA)   

# Users Temp Files Variables
$usrs = Get-ChildItem C:\Users 

# Windows Temp files Variables
$WinTemp = "c:\Windows\Temp\*"   

<########################################################>	    

<# 	Task #1
	Backup and CleanUp EventsLogs 
    1. Crea un directorio con el nombre de cada Log.
    2. Realiza Backup de todos los eventos por Log y se guardan con la fecha.
    3. limpia todos los eventos.
#>
foreach ($eventl in $eventls)
{
    $dir = New-Item -Path $path -Name $eventl.Log -ItemType Directory
    $logpath = "$dir\$date.evtx"
	write-Host "Backup EventLog $eventl.Log in $dir" -ForegroundColor Magenta 
    wevtutil export-log $eventl.Log $logpath
    sleep 1
	write-Host "CleanUp EventLog $eventl.Log" -ForegroundColor DarkYellow
    wevtutil clear-log $eventl.Log
}

<#  Task #2
	Remove temp files located in "C:\Users\USERNAME\AppData\Local\Temp" 
#>
foreach ($usr in $usrs)
{
	$path = "C:\Users\$usr\AppData\Local\Temp"
	write-Host "Removing Junk files in $path." -ForegroundColor Yellow  
	Remove-Item -Recurse  "$path\*" -Force -Verbose
}

<# Task #3
	Empty Recycle Bin 
#> 
write-Host "Emptying Recycle Bin." -ForegroundColor Blue    
$objFolder.items() | %{ remove-item $_.path -Recurse -Confirm:$false}   
	  
<# Task #4
	Remove Windows Temp Directory
#> 
write-Host "Removing Junk files in $WinTemp." -ForegroundColor Red   
Remove-Item -Recurse $WinTemp -Force    
	  
<# Task #5
	Running Disk Clean up Tool
#>   
write-Host "Finally now , Running Windows disk Clean up Tool" -ForegroundColor Green   
cleanmgr /sagerun:10 | out-Null    	   
    $([char]7)   
    Sleep 1    
    $([char]7)   
    Sleep 1  
          	
write-Host "Clean Up Task Finished !!!"
########## End of the Script ##########
