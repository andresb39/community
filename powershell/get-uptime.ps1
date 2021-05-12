Function Get-Uptime {
Param ( [string] $ComputerName = $env:COMPUTERNAME )
$os = Get-WmiObject win32_operatingsystem -ComputerName $ComputerName -ErrorAction SilentlyContinue
 if ($os.LastBootUpTime) {
    $uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)
    Write-Output ("Last boot: " + $os.ConvertToDateTime($os.LastBootUpTime) )
    Write-Output ("Uptime   : " + $uptime.Days + " Days " + $uptime.Hours + " Hours " + $uptime.Minutes + " Minutes" )
  }
  else {
    Write-Warning "Unable to connect to $computername"
  }
}
