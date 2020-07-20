Write-host "Functions: Send-Clock, Reset-Password, Unlock-ADAaccount, Connect-365 are available" -ForegroundColor Green

function Reset-Password{

    param (
        [string]$identity = $(Read-Host "Identity"),
        [string]$password = $(Read-Host "Password")
    )

    $ADuser =  Get-ADUser $identity
        If($ADuser) 
        { 
            try{
                Set-ADAccountPassword $identity -reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
                Write-Host "Password Changed to $password" -ForegroundColor Green 
            }
            catch{
                Write-Host "Error:"$_.Exception.Message  -ForegroundColor Red
                return
            }

            $NeverExpires = Get-ADUser -identity $ADuser -Properties PasswordNeverExpires
            if(-not $NeverExpires.PasswordNeverExpires){
                Set-ADUser $identity -ChangePasswordAtLogon $true
            }
            else{
                Write-Host "Never Expire is set to true so they will have manually reset their password" -ForegroundColor Green 
            }
          
        }
}

function Send-Clock{
    py.exe C:\DEV\Python\Clock\clock.py
}


function Connect-365{

    $adminUPN=$SECRETadminUPN
    $orgName=$SECRETorgName
    
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

    Write-Host "Useful Functions: Get-EXOMailbox, Get-EXOMailboxPermission, " -ForegroundColor Green

}