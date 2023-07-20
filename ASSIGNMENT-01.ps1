# establish Logging mechanism

class LogEntry {
    [bool]$Active=$true
    [DateTime]$Timestamp
    [string]$Operation
    [string]$Description
    [TimeSpan]$Duration
    [String]$Status

    LogEntry(
        [String]$Operation,
        [String]$Description,
        [switch]$Closed=$false
    ){
        if( $Closed ) { $this.Active=$false }
        $this.Timestamp=[DateTime]::Now
        $this.Operation=$Operation
        $this.Description=$Description
        $this.Duration=[TimeSpan]::Zero
        $this.Status="Open"
    }

    [LogEntry]UpdateLogEntry(
        [Switch]$Close,
        [String]$Status,
        [switch]$Quiet
    ){
        if( $this.$Close ) {
            $this.Active = $false
        }
        $this.Duration = [DateTime]::Now - $this.Timestamp
        if($Status) { $this.Status = $Status }
    
        if( -not $Quiet ) {
            Write-Host -ForegroundColor Gray "Update " -NoNewline
            Write-Host "$($this.Operation)/$($this.Description), $($this.Status)"
        }
        
        return $this;
    }
}

class LogTrail {
    [System.Collections.Generic.List[LogEntry]]$logs

    LogTrail(){
        $this.logs = [System.Collections.Generic.List[LogEntry]]::new()
    }

    [LogEntry]NewLogEntry(
        [LogEntry]$LogEntry,
        [switch]$Quiet=$false
    ){
        if( -not $Quiet ) {
            Write-Host -ForegroundColor Cyan "Starting " -NoNewline
            Write-Host "$($LogEntry.Operation) / $($LogEntry.Description)..."
        }
        $this.logs.Add($LogEntry)
        return $LogEntry
    }
    
    [LogEntry]NewLogEntry(
        [String]$Operation,
        [String]$Description,
        [bool]$Quiet=$false
    ){
        return $this.NewLogEntry(
            [LogEntry]::new(
                $Operation,$Description,$false
            )
            ,$Quiet
        )
    }
    [LogEntry]NewLogEntry(
        [String]$Operation,
        [String]$Description
    ){
        return $this.NewLogEntry(
            $Operation,
            $Description,
            $false
        )
    }

    [LogEntry]NewClosedLogEntry(
        [String]$Operation,
        [String]$Description,
        [switch]$Quiet=$false
    ){
        return $this.NewLogEntry(
            [LogEntry]::new(
                $Operation,$Description,$false
            )
            ,$Quiet
        )
    }    
}
$script:LogTrail = [LogTrail]::new()

function Invoke-LoggedAction{
[CmdletBinding()]param(
    [Parameter(Mandatory,Position=0)]
    [scriptblock]$Action,
    [String]$Operation,
    [String]$Description,
    [switch]$Quiet
)
    $log = $LogTrail.NewLogEntry(
        $Operation,
        $Description,
        $Quiet
    )
    try {
        return & $Action $log $Quiet -ErrorAction Stop
    } catch {
        $local:Err = $_
    
        $local:formatstring = "ERROR: {0} : {1}`n {2}`n" + 
                    " + CategoryInfo          : {3}`n" +
                    " + FullyQualifiedErrorId : {4}`n"
    
        $local:fields = $Err.InvocationInfo.MyCommand.Name,
                        (@($Err.ErrorDetails, $Err.Exception) | Where-Object {$_.Message} | Select-Object -First 1 -ExpandProperty Message),
                        $Err.ScriptStackTrace,
                        $Err.CategoryInfo.ToString(),
                        $Err.FullyQualifiedErrorId
    
        $log = $log.UpdateLogEntry($true,($formatstring -f $fields),$Quiet)

        throw $Err
    } finally {
        if( $log.Active ) {
            $null = $log.UpdateLogEntry($true,"",$Quiet)
        }
    }
}

try {
    # Check that AzureAD commands are available
    $Action = [ordered]@{
        Operation="Get-Command Get-MgContext"
        Description="Checking Microsoft.Graph Module command is available"
        Action={param([LogEntry]$log,$Quiet)
            $null = Get-Command Get-MgContext -ErrorAction Stop
            $null = $log.UpdateLogEntry($true,"Success",$Quiet)        
        }
    }
    Invoke-LoggedAction @Action -Quiet

    $Action = [ordered]@{
        Operation="Get-MgOrganization"
        Description="Testing connection to Microsoft.Graph"
        Action={param([LogEntry]$log,$Quiet)
            $org = Get-MgOrganization
            $null = $log.UpdateLogEntry(
                $true,
                "Connected to $(
                    $org.DisplayName) on $(
                    $org.VerifiedDomains | Where-Object IsDefault |
                        Select-Object -ExpandProperty Name
                )",
                $Quiet
            )
        }
    }
    Invoke-LoggedAction @Action -Quiet

} catch {
# We are relying on the LogTrail to show us any problems.
}
finally {
    $LogTrail.logs | Format-Table -Wrap
}

# Create the group if it does not already exist.
# Iterate through the list of users, for each
# If the user doesn't exist, it will create the user.
# If the user isn't a member of the above mentioned group, add it to it.
# Display a report.