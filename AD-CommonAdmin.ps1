Write-host "Useful Functions: Send-Clock, Reset-Password, Unlock-ADAaccount, Send-Logoff, New-ServiceAccount, Connect-365" -ForegroundColor Green

function Reset-Password {

    param (
        [string]$identity = $(Read-Host "Identity"),
        [string]$password = $(Read-Host "Password")
    )

    $ADuser = Get-ADUser $identity
    If ($ADuser) { 
        try {
            Set-ADAccountPassword $identity -reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
            Write-Host "Password Changed to $password" -ForegroundColor Green 
        }
        catch {
            Write-Host "Error:"$_.Exception.Message  -ForegroundColor Red
            return
        }

        $NeverExpires = Get-ADUser -identity $ADuser -Properties PasswordNeverExpires
        if (-not $NeverExpires.PasswordNeverExpires) {
            Set-ADUser $identity -ChangePasswordAtLogon $true
        }
        else {
            Write-Host "Never Expire is set to true so they will have manually reset their password" -ForegroundColor Green 
        }
          
    }
}

function Send-Clock {
    py.exe C:\DEV\Python\Clock\clock.py
}


function Connect-365 {

    $adminUPN = $SECRETadminUPN
    $orgName = $SECRETorgName
    
    ##Azure Active Directory
    Connect-AzureAD -AccountId $adminUPN
    
    ##SharePoint Online
    #Connect-SPOService -Url https://$orgName-admin.sharepoint.com
    
    ##Skype for Business Online
    #$sfboSession = New-CsOnlineSession -UserName adminUPN
    #Import-PSSession $sfboSession
    
    ##Exchange Online
    Connect-ExchangeOnline -UserPrincipalName $adminUPN -ShowProgress $true
    
    ##Teams
    #Import-Module MicrosoftTeams  
    Connect-MicrosoftTeams -AccountId $adminUPN

    Write-Host "Useful Functions: Get-EXOMailbox, Get-EXOMailboxPermission" -ForegroundColor Green

}

function Send-Logoff {

    param (
        [string]$computer = $(Read-Host "Computer name"),
        [string]$user)
    
    
    $sb = {

        param($user)
             
    
        quser
        write-host $user
        if ($user -eq "") {
            $user = $(Read-Host "Which user do you want to log off?")
        }
        $sessions = quser | Where-Object { $_ -match $user }

        $sessionIds = ($sessions -split ' +')[2]
        
        Write-Host "Found $(@($sessionIds).Count) user login(s) on computer."
        
        $sessionIds | ForEach-Object {
            Write-Host "Logging off session id [$($_)]..."
            logoff $_
        }
 

    }

    Invoke-Command -ComputerName $computer -ScriptBlock $sb -ArgumentList $user   
}

function New-ServceAccount {

    param (
        [string]$computer = $(Read-Host "Which computer is the service account for?"),
        [string]$name = $(Read-Host "What is the service account name?")
    )

    New-ADServiceAccount -Name $name -RestrictToSingleComputer
    Add-ADComputerServiceAccount -Identity $computer -ServiceAccount $name

    New-ADServiceAccount -Name $name -RestrictToSingleComputer
    Add-ADComputerServiceAccount -Identity $computer -ServiceAccount $name

    Enter-PSSession $computer
    Add-WindowsFeature RSAT-AD-PowerShell
    Install-ADServiceAccount -Identity $name
    Test-ADServiceAccount $name
    Exit-PSSession

    Write-Host "Still need to add permissions to the service account" -ForegroundColor Green
    Write-Host "The below command is to update a scheduled task" -ForegroundColor Green
    Write-Host "schtasks /Change /TN 'TASK-NAME' /RU $name /RP " -ForegroundColor Green

}