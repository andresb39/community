<#
    .Autor: Jesus Bergano
    .Fecha: 14/04/2020
    .Version: 1.0
    .Notas:
        Este script nos permite obtener informacion acerca del IIS y los sitios.
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
            Invoke-Command -ComputerName $computer -ScriptBlock {Set-ExecutionPolicy Bypass |   Import-Module WebAdministration }
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
                foreach ($webapp in $iisinfo.Name){
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
$location = Get-Location
$report | Export-Csv "$location\iisreport.csv"