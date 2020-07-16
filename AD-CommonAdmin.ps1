Import-Module -Name ActiveDirectory -Function Set-ADAccountPassword, Set-ADuser, Unlock-ADAccount

Write-host "Functions: Reset-Password, Unlock-ADAaccount are available" -ForegroundColor Green

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