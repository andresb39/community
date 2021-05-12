<#
    .Autor: Jesus Bergano
    .Fecha: 14/04/2020
    .Edit: 15/04/202
    .Version: 2.0
    .Notas:
        Este script nos permite obtener informacion acerca del IIS y los sitios.
    .prerequisito:
        archivo .txt con listado de servidores.
    .ejecucion:
        solo basta con ejecutarlo ./iisinfo.ps1 este nos va a solicitar un .txt con el listado de servidores
#>

<# Funcion que nos abre un cuadro de dialogo para obtener un listado de servidore #>
function Read-OpenFileDialog([string]$WindowTitle, [string]$InitialDirectory, [string]$Filter = "All files (*.*)|*.*", [switch]$AllowMultiSelect)
{
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = $WindowTitle
    if (![string]::IsNullOrWhiteSpace($InitialDirectory)) { $openFileDialog.InitialDirectory = $InitialDirectory }
    $openFileDialog.Filter = $Filter
    if ($AllowMultiSelect) { $openFileDialog.MultiSelect = $true }
    $openFileDialog.ShowHelp = $true    # Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE.
    $openFileDialog.ShowDialog() > $null
    if ($AllowMultiSelect) { return $openFileDialog.Filenames } else { return $openFileDialog.Filename }
}

<# llamado a la funcion creada arriba #>
$filePathsrv = Read-OpenFileDialog -WindowTitle "INGRESE EL ARCHIVO QUE CONIENE EL LISTADO DE SERVIDORES" -InitialDirectory 'C:\' -Filter "Text files (*.txt)|*.txt"
if (![string]::IsNullOrEmpty($filePathsrv)) { Write-Host "You selected the file: $filePathsrv" }
else { "No selecciono ningún archivo." }

$computers = Get-Content $filePathsrv
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
