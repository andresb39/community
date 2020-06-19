<#
  Kill sesions windows servers
  Autor: Jesus A. Bergano.
  Version: 2.0
  Ejecucion: .\kill_session.ps1 -username username
             .\kill_session.ps1 -username username -Verbose
#>

Function kill_session{
  param(
    [parameter(Mandatory)]
    [string]$username
  )
  Write-Verbose "Get Windows Servers"
  $computers = Get-ADComputer -Filter { (OperatingSystem -like 'Windows*Server*201*') -or (OperatingSystem -like 'Windows*Server*2008*')} -Properties OperatingSystem | Select Name

  Foreach ($computer in $computers.Name){
    Write-Verbose "Test conection $computer"
    if((Test-Connection -ComputerName $computer -Quiet -ErrorAction SilentlyContinue) -eq $true){
      Write-Verbose "Get Sessions"
      $sessions = Invoke-Command -ComputerName $computer -ErrorAction SilentlyContinue -ScriptBlock { Get-Process -IncludeUserName -ErrorAction SilentlyContinue | Select-Object UserName,SessionId | Where-Object { $_.UserName -ne $null -and $_.UserName.StartsWith("BUE299") } | Sort-Object SessionId -Unique } | Select-Object UserName,SessionId
      if($sessions.UserName -like $username){
        Write-Verbose "Kill Sessions $sessions.UserName"
        Write-Host "Sesion en servidor $computer" -ForegroundColor Red
        rwinsta /server:$computer $sessions.SessionId | Out-Null
      }
      else{
        Write-Verbose "No session"
        Write-host "No hay sesiones $computer" -ForegroundColor Green
      }
    }
  }
}
kill_session
