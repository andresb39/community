<#
  .Synopsis
    Depuracion de logs de IIS

  .DESCRIPTION
    Con este escript vamos a poder realizar la depuracion de los logs de IIS

  .EXAMPLE
    .\inetpub_cleanuplogs.ps1 -server localhost
    .\inetpub_cleanuplogs.ps1 -server servername

  .NOTES
    Autor: Jesus A. Bergano G.
    Version: V1.0
    Fecha: Septiembre. 2020
#>

param(
  [parameter(Mandatory)]
  [string]$server
)
$commands = {
  Get-ChildItem -Path C:\inetpub\logs\LogFiles -Recurse -ea 0 |
    Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-31) } |
    ForEach-Object { $_ | Remove-Item -Force -Confirm:$false } 
}

Invoke-Command -ComputerName $server -ScriptBlock $commands
