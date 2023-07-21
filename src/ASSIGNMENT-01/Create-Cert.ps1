# Following guide on:
# <https://learn.microsoft.com/en-us/graph/tutorials/powershell-app-only?tabs=linux-macos&tutorial-step=1>
#
# This script creates a new
[CmdletBinding()]param([switch]$Force) # This adds common parameters, like ErrorAction

$local:Create = -not (
    (Test-Path 'powershell-app.pem') -and
    (Test-Path 'powershell-app.crt') -and
    (Test-Path 'powershell-app.key')
)
if( $Force -or $Create ) {
    foreach( $local:ext in @('.key', '.pem', '.crt', '.pfx') ) {
        if( Test-Path "powershell-app${ext}" ) {
            Remove-Item -Force -LiteralPath "powershell-app${ext}" -Verbose
            $Create = $true
        }
    }
}
if( $Create ) {
    # Create private key
    & openssl genrsa -des3 -out powershell-app.key `
        -passout "pass:keypassphrase" `
        2048
        # -passout pass:... usage is ONLY acceptable in insecure testing env.
    
    # Create Signed Certificate with DES3 Encryption (with an INSECURE passkey)
    & openssl req -x509 `
        -key 'powershell-app.key' -passin  "pass:keypassphrase" `
        -sha256 -days 365 -subj '/CN=PowerShell App-Only' `
        -out 'powershell-app.crt' `
        -passout "pass:pempassphrase"
        # -passin/passout pass:... usage is ONLY acceptable in insecure
        # testing env.
    
    # Expose the public key for easy copying by non-root users
    chmod 664 'powershell-app.crt'

    if( Test-Path 'powershell-app.pfx' ) { Remove-Item 'powershell-app.pfx' }

    Write-Host -ForegroundColor Green "`nKEY, PEM and CRT certificate files created`n"
}

if( -not (Test-Path 'powershell-app.pfx') ) {
    $Create = $true
    # Self-Sign Certificate Request
    & openssl pkcs12 -export -in 'powershell-app.crt' `
        -inkey 'powershell-app.key' -passin  "pass:keypassphrase"`
        -out 'powershell-app.pfx' -passout "pass:pfxpassphrase"
        # -passin/passout pass:... usage is ONLY acceptable in insecure
        # testing env.

    Write-Host -ForegroundColor Green "`nPFX certificate file created`n"
    Write-Host "You can now load certificate by running ./src/Load-Cert.ps1"
    Write-Host ""
    Write-Host -ForegroundColor Red "NOTE: You will need to register this certifcate!"
    Write-Host "Grab the powershell-app.crt public key file and Follow"
    Write-Host "instructions in the tutorial link below: (very long link)"
    Write-Host "  https://learn.microsoft.com/en-us/graph/tutorials/powershell-app-only?tabs=linux-macos&tutorial-step=1#register-application-for-app-only-authentication"
    Write-Host ""
    }

$Cert = ./src/Load-Cert.ps1 -Force:$Create
Write-Host -ForegroundColor Green "Certificate loaded with ./src/Load-Cert.ps1"
Write-Host ""
Write-Host -ForegroundColor Yellow "Recommendation:"
Write-Host "If you haven't already, it is recommended you create a script "
Write-Host "./src/Connect-AppCert.ps1 to quickly connect. It should have at"
Write-Host "least the following content:"
Write-Host "########################################################################################"
Write-Host "`$clientId='<Client ID of the Application>'            # Get this from the Azure Portal"
Write-Host "`$tenantID='<Tenant ID of Azure AD>'                   # Get this from the Azure Portal"
Write-Host "`$certThumb='$($Cert.Thumbprint                     )' # grabbed from ./src/Load-Cert.ps1"
Write-Host ""
Write-Host 'Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumb $certThumb'
Write-Host "########################################################################################"
Write-Host ""
Write-Host "NOTE that Connect-AppCert.ps1 is listed in .gitignore and will not be saved to the git repo due to it's sensitive nature."