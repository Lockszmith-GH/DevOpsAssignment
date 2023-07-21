using namespace System.Security.Cryptography.X509Certificates
[CmdletBinding()]param([switch]$Force) # This adds common parameters, like ErrorAction

# Code from https://stackoverflow.com/a/42108420/799379
# Since this is mimicing a C# clause, the verb isn't an approved one.
# If you see a Warning, it's OK. This was an intentional choice.
function Using-Object {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $InputObject,

        [Parameter(Mandatory = $true, Position=1)]
        [scriptblock]
        $ScriptBlock
    )

    try
    {
        Invoke-Command $ScriptBlock
    }
    finally
    {
        if ($InputObject -is [System.IDisposable])
        {
            $InputObject.Dispose()
            Write-Verbose "IDisposable Disposed"
        }
    }
}

Using-Object ([X509Store]::new('My', 'CurrentUser', 'ReadWrite') | Tee-Object -Variable store) {
    $local:Cert = $store.Certificates |
        Where-Object Subject -eq "CN=PowerShell App-Only"
    if( $tst -and $Force ) {
        $store.Remove($Cert);
        $Cert = $null
    }
    if( -not $Cert ) {
        $store.Add([X509Certificate2]::new(
            './powershell-app.pfx',
            "pfxpassphrase", # BAD PRACTICE: Hard coded - BEWARE
            [X509KeyStorageFlags]::PersistKeySet)
        )
            
        $Cert = $store.Certificates |
            Where-Object Subject -eq "CN=PowerShell App-Only"

        if( -not $Cert ) {
            throw "Failed to create certificate"
        }

        Write-Host -ForegroundColor Green "Certificate created"
    }
    $Cert
}
$store = $null