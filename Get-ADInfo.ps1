<#
    .Synopsis
        Active Directory Report.

    .DESCRIPTION
        Este script vamos a poder optener los siguientes reportes del AD:
            Usuarios / Computadoras 90 dias LastLogon.
            Usuarios / Computadoras Deshabilitados.
            Active Directory Report: Sites, Domains, Subnets, Servers y Adjacent Sites.
            TrustRelationships.
            RecycleBin Status.
            Replication. 
            
    .EXAMPLE
        Import-Module .\Get-ADInfo.ps1
        Get-ADInfo 

    .NOTES
        Ingresar la direccion de correo a quien se enviara el reporte es obligatorio.
        Modifique el SMTP a vuestra necesidad.

        Autor: Jesus A. Bergano G.
        Version: V1.0
        Fecha: Nov. 2019
#>
function Get-ADInfo {
    
    # Variables #
    $date = Get-Date
    $old = $date.Date.AddDays(-90)

    # Importing AD Module #
    Write-Verbose -Message "Importing active directory module"
    if (! (Get-Module ActiveDirectory) ) {
        Import-Module ActiveDirectory -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Write-Verbose -Message "Active directory Module import successfully"
    }
    else { 
        Write-Verbose -Message "ActiveDirectory Powershell Module Already Loaded"
    } 

    function Menu {   
        Clear-Host
        Write-Host "================ $Title ================"
        Write-Host "1: Press '1' Usuarios con ultimo logueo mayor a 90 dias."
        Write-Host "2: Press '2' Computadoras con ultimo logueo mayor a 90 dias."
        Write-Host "3: Press '3' Usuarios deshabilitados."
        Write-Host "4: Press '4' Computadoras deshabilitadas."
        Write-Host "5: Press '5' ActiveDirectory Report: Sites, Domains, Subnets, Servers and Adjacent Sites."
        Write-Host "6: Press '6' TrustRelationships."
        Write-Host "7: Press '7' RecycleBin Status."
        Write-Host "8: Press '8' Replication."
        Write-Host "Q: Press 'Q' to quit."
    }

    function Userlastlogondate {
        Write-Verbose -Message "Get Users lastlogondate"
        Get-ADUser -Filte { lastlogondate -le $old } -pr lastlogondate | 
        Sort-Object -property lastlogondate | 
        Select-Object @{N = "Account Name"; E = { $_.samaccountname } }, @{N = "Last Logon"; E = { $_.lastlogondate } }, @{N = "OU"; E = { $_.DistinguishedName } } |
        Format-Table -AutoSize
    }
    function CompLastLogondate {
        Get-ADComputer -Filter { lastlogondate -le $old } -pr lastlogondate | 
        Sort-Object -Property lastlogondate | 
        Select-Object @{N = "Account Name"; E = { $_.samaccountname } }, @{N = "Last Logon"; E = { $_.lastlogondate } }, @{N = "OU"; E = { $_.DistinguishedName } } | 
        Format-Table -AutoSize
    }

    function UserDisable {
        Get-ADUser -Filter * -Property Enabled | 
        Where-Object { $_.Enabled -like "false" } | 
        Select-Object @{N = "Account Name"; E = { $_.samaccountname } }, @{N = "Enabled"; E = { $_.Enabled } }, @{N = "OU"; E = { $_.DistinguishedName } } |
        Format-Table -AutoSize
    }

    function CompDisable {
        Get-ADComputer -Filter * -Property Enabled | 
        Where-Object { $_.Enabled -like "false" } | 
        Select-Object @{N = "Account Name"; E = { $_.samaccountname } }, @{N = "Enabled"; E = { $_.Enabled } }, @{N = "OU"; E = { $_.DistinguishedName } } | 
        Format-Table -AutoSize
    }

    function ADReport {
        $sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

        foreach ($site in $sites.Sites) {
            $site | Select-Object  Domains, Subnets, Servers, AdjacentSites 
            $result.Domains | Select-Object Forest, Name, PdcRoleOwner | Format-Table -AutoSize
            $result.Subnets | Format-Table -AutoSize
            $result.Servers | Select-Object Name, OSVersion, IPAddress | Format-Table -AutoSize
            $result.AdjacentSites | Select-Object name | Format-Table -AutoSize
        }
    }

    function TrustRelations {
        $trust = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().GetAllTrustRelationships()
        $trust | Select-Object SourceName, TargetName, TrustDirection | Format-Table -AutoSize
    }

    function RecycleBin {
        Write-Verbose "Get Optinal features"
        if ((Get-ADOptionalFeature -filter *).EnabledScopes -eq $empty) {
            Write-Host "RecycleBin is Disabled" -foregroundcolor Red
        } 
        else {
            Write-Host "RecycleBin is Enabled" -ForegroundColor Green
        }
    }

    function ShowReplicate {   
        $getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
        $DCServers = $getForest.domains | ForEach-Object { $_.DomainControllers } | ForEach-Object { $_.Name } 
        foreach ($DC in $DCServers) {
            if (Test-Connection -ComputerName $DC -Count 1 -ErrorAction SilentlyContinue) {
                Write-Verbose -Message "$DC `t $DC `t Ping Success"
                repadmin /showrepl $DC 
            }
        } 
    }

    do {
        Menu
        $options = Read-Host "Please make a selection"
        switch ($options) {
            '1' {
                Clear-Host
                'You chose option #1'
                Userlastlogondate
            } 
            '2' {
                Clear-Host
                'You chose option #2'
                CompLastLogondate
            } 
            '3' {
                Clear-Host
                'You chose option #3'
                UserDisable
            } 
            '4' {
                Clear-Host
                'You chose option #4'
                CompDisable
            }
            '5' {
                Clear-Host
                'You chose option #5'
                ADReport
            }
            '6' {
                Clear-Host
                'You chose option #6'
                TrustRelations
            }
            '7' {
                Clear-Host
                'You chose option #7'
                RecycleBin
            }
            '8' {
                Clear-Host
                'You chose option #8'
                ShowReplicate
            }
            'q' {
                return
            }
        }
        pause
    }
    until ($options -eq 'q')
}
