<#
  Kill sesions windows servers
  Este script usa el ps1 servers_list donde tendremos el lisardo de los servidores.
  Ejecucion: .\kill_session.ps1 -username username
#>

param(
  [parameter(Mandatory)]
  [string]$username
)

# Agregamos listado de servidores
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$($scriptPath)\servers_list.ps1"

$id = @()
try{
  foreach($srv in $servers){
    $sesion = query session $username /server:$srv
    #Search user session ID

    if($sesion -eq $null){
      Write-host "No hay sessiones $srv" -ForegroundColor Green
    }
    Else{
        ForEach($ssid in $sesion){
          $splitUp = $ssid -split "\s+"
          $line = $splitUp[0]
          $id = $splitUp[3]
      }
      Write-Host "Kill Sesion $id $srv" -ForegroundColor Red
      rwinsta /server:$srv $id | Out-Null
    }
  }
}
catch{
  write-host "Error" -ForegroundColor Red
}
