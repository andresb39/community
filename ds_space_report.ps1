<#
    Creado: Jesus Bergano
    Fecha: 25/03/2020
    Version: 2.0
    Prerequisito: Tener instalado VMware.PowerCli
#>
$server = "IP / FQND vCenter Server"
$user = "Username"
$pass = "Password"

<# Importacion de modulo PowerCli y conexion al vCenter #>
Import-Module VMware.PowerCLI -Force 
Connect-VIServer -Server $server -User $user -Password $pass -Force | Out-Null

$mailParam = @{
    To =  "to@tucompañia.com"
    From = "vCenter@tucompañia.com"
    Subject = "Datastorage Status"
    SmtpServer = "SMTP Server"
    BodyAsHtml = $true
    Priority = "High"
   }

<# Creacion de Variables #>
$htmlreport = @()
$report = @()
$ds = Get-Datastore

<# Buscar DataStorages #>
foreach ($dsn in $ds)
{
    <# Filtrar Datastorage locales #>
    if ($dsn.name -notlike  'datastore1*')
    {         
       [Int]$freeAV = $dsn.FreeSpaceGB * 100 / $dsn.CapacityGB

       <# Filtramos los DS con menos de 5% de espacio libre #>
       if ($freeAV -le 5)
       {      
            
            Get-Datastore -Name $dsn.Name | ForEach-Object {  
                $dsinfo = $_
                    $x = [Int]$dsinfo.CapacityGB / 1024
                    $y = [Int]$dsinfo.FreeSpaceGB
                    $row = New-Object -TypeName PSObject
                    $row | Add-Member -MemberType NoteProperty -Name DS_Name -Value $dsinfo.Name
                    $row | Add-Member -MemberType NoteProperty -Name DS_CapacityTB -Value "$x TB"
                    $row | Add-Member -MemberType NoteProperty -Name DS_FreeSpaceGB -Value "$y GB"
                    $row | Add-Member -MemberType NoteProperty -Name DS_Free -Value "$freeAV %" 
                    $report += $row  
            }       
               
       }#Close IF2    
    }#Close IF1
}#close Foreach

$fragments = @()
$fragments+= "<H1>$("Storage Report PRD Alert Space")</H1>"
[xml]$html = $report | convertto-html -Fragment
 
for ($i=1;$i -le $html.table.tr.count-1;$i++) {
  if ($html.table.tr[$i].td[4] -le 5) {
    $class = $html.CreateAttribute("class")
    $class.value = 'alert'
    $html.table.tr[$i].childnodes[3].attributes.append($class) | out-null
  }
}
$fragments+= $html.InnerXml
$fragments+= "<p class='footer'>$(get-date)</p>"
$fragments+= "<p class='footer'><b>$("Muchas Gracias")</b></p>"
$fragments+= "<p class='footer'><b>$("Gestion de Cambios")</b></p>"
$fragments+= "<p class='footer'><b>$("Banco Comafi")</b></p>"
$convertParams = @{ 
  head = @"
 <Title>Event Log Report</Title>
<style>
  BODY{font-family: Arial; font-size: 8pt; Background-color:silver}
	H1{font-size: 14px; color:red}
	TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
	TH{border: 1px solid black; background: Green; padding: 5px; color: white; text-align: center;}
	TD{border: 1px solid black; padding: 5px; text-align: right;}
  .alert {color: red; font-weight:bold;}
  .footer{ color:green; margin-left:10px; font-family:Tahoma;  font-size:8pt; font-style:italic;}
</style>
"@
 body = $fragments
}

$htmlreport  =  convertto-html @convertParams | Out-String

<# Envio de mail si hay DS con alerta #>
if($htmlreport -ne $null)
{
        Send-MailMessage @mailParam -Body $htmlreport
}

<# Disconect to vCenter#>
Disconnect-VIServer -Server $server -Force -Confirm:$false