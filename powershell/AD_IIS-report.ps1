<#
    .Autor: Jesus Bergano
    .Fecha: 14/04/2020
    .Version: 1.0
    .Notas:
        Este script nos permite obtener informacion acerca del IIS y los sitios web.
#>

$computers = Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true"'
$report = @()

<# Obtencion de informacion y armado del reporte #>
foreach($computer in $computers){
    if((Test-Connection -ComputerName $computer -Quiet) -eq $true){
        $connection =  Get-Service -ComputerName $computer -ServiceName "W3SVC" -ErrorAction SilentlyContinue
        if($connection.Status -eq "Running"){
            Invoke-Command -ComputerName $computer -ErrorAction  SilentlyContinue -ScriptBlock {Set-ExecutionPolicy Bypass |   Import-Module WebAdministration }
            $iisinfos = Invoke-Command -ComputerName $computer -ErrorAction  SilentlyContinue -ScriptBlock { Get-Website }
            foreach($iisinf in $iisinfos){
                $row = New-Object -TypeName PSObject
                $row | Add-Member -MemberType NoteProperty -Name Server -Value $iisinf.PSComputerName
                $row | Add-Member -MemberType NoteProperty -Name "Site Name" -Value $iisinf.Name
                $row | Add-Member -MemberType NoteProperty -Name ID -Value $iisinf.ID
                $row | Add-Member -MemberType NoteProperty -Name State  -Value $iisinf.State
                $row | Add-Member -MemberType NoteProperty -Name "Physical Path" -Value $iisinf.physicalPath
                $row | Add-Member -MemberType NoteProperty -Name  Bindings -Value $iisinf.bindings.Collection
                $report += $row
                foreach ($webapp in $iisinf.Name){
                    $webappinfo = Invoke-Command -ComputerName $computer  -ScriptBlock { Get-WebApplication -Site "$webapp"}
                    foreach ($webappinf in $webappinfo){
                    $row = New-Object -TypeName PSObject
                    $row | Add-Member -MemberType NoteProperty -Name "Site Name" -Value $webappinf.path
                    $row | Add-Member -MemberType NoteProperty -Name "Physical Path" -Value $webappinf.physicalPath
                    $report += $row
                    }
                }
            }
        }
    }
}


$fragments = @()
$fragments+= "<H1>$("IIS Report")</H1>"
$fragments+= $report | convertto-html -Fragment
$fragments+= "<p class='footer'>$(get-date)</p>"
$convertParams = @{
  head = @"
 <Title>IIS Report</Title>
<style>
  BODY{font-family: Arial; font-size: 8pt; Background-color:silver}
    H1{font-size: 14px; color:Black}
    TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
    TH{border: 1px solid black; background: Green; padding: 5px; color: white; text-align: center;}
    TD{border: 1px solid black; padding: 5px; text-align: right;}
  .footer{ color:green; margin-left:10px; font-family:Tahoma;  font-size:8pt; font-style:italic;}
</style>
"@
 body = $fragments
}

$htmlreport  =  convertto-html @convertParams | Out-String
$date = get-date -Format ddMMyyhhmmss
$location = Get-Location
$htmlreport | Out-File "$location\iisreport_$date.html"
Invoke-Item "$location\iisreport_$date.html"
