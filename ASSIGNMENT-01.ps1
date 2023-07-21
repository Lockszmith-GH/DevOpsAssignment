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
        if( $Close ) {
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
    [Parameter(Mandatory,Position=1)]
    [String]$Operation,
    [Parameter(Mandatory,Position=2)]
    [String]$Description,
    [switch]$Quiet,
    [Parameter(ValueFromRemainingArguments,Position=3)]
    $more_args
)
    $log = $LogTrail.NewLogEntry(
        $Operation,
        $Description,
        $Quiet
    )
    try {
        Invoke-Command -ScriptBlock $Action -ArgumentList @(
                $log, $Quiet, $more_args
            ) -ErrorAction Stop
    } catch {
        $local:Err = $_
    
        $local:formatstring = "ERROR: {0} : {1}`n {2}`n" + 
                    " + CategoryInfo          : {3}`n" +
                    " + FullyQualifiedErrorId : {4}`n" +
                    " + Invoke-LoggedAction args: {5}`n"
    
        $local:fields = $Err.InvocationInfo.MyCommand.Name,
                        (@($Err.ErrorDetails, $Err.Exception) | Where-Object {$_.Message} | Select-Object -First 1 -ExpandProperty Message),
                        $Err.ScriptStackTrace,
                        $Err.CategoryInfo.ToString(),
                        $Err.FullyQualifiedErrorId,
                        ($more_args -join ', ')
    
        $log = $log.UpdateLogEntry($true,($formatstring -f $fields),$Quiet)

        throw $Err
    } finally {
        if( $log.Active ) {
            $log.UpdateLogEntry($true,"",$Quiet)
        }
    }
}

# Initial tests
# Create the group if it does not already exist.
# Iterate through the list of users, for each
# If the user doesn't exist, it will create the user.
# If the user isn't a member of the above mentioned group, add it to it.
# Display a report.
$script:Domain="unknown"

$Automation = @(
    [ordered]@{
        Operation="Get-Command Get-MgContext"
        Description="Checking Microsoft.Graph Module command is available"
        Action={param([LogEntry]$log,$Quiet)
            $null = Get-Command Get-MgContext -ErrorAction Stop
            $log.UpdateLogEntry($true,"Success",$Quiet)        
        }
    },
    [ordered]@{
        Operation="Get-MgOrganization"
        Description="Testing connection to Microsoft.Graph"
        Action={param([LogEntry]$log,$Quiet)
            $org = Get-MgOrganization -ErrorAction Stop
            $script:Domain = $org.VerifiedDomains |
                Where-Object IsDefault |
                Select-Object -ExpandProperty Name
            $log.UpdateLogEntry(
                $true,
                "Connected to $($org.DisplayName) on $Domain",
                $Quiet
            )
        }
    },
    [ordered]@{
        Operation="Create Group"
        Description="Varonis Assignment Group"
        Action={param([LogEntry]$log,$Quiet)
            $Group = Get-MgGroup -Filter "DisplayName eq 'Varonis Assignment Group'"
            if( $Group ) {
                $log.UpdateLogEntry($true, "Group already exists $($Group.Id)", $Quiet )    
            } else {
                $NewGroup = @{
                    DisplayName = "Varonis Assignment Group"
                    Description = "Varonis Assignment Group"
                    GroupTypes = @()
                    MailNickname = 'vrns-assign-grp'
                    MailEnabled = $false
                    SecurityEnabled = $true
                }
                $Group = New-MgGroup @NewGroup -ErrorAction Stop
                $log.UpdateLogEntry($true, "Group Created $($Group.Id)", $Quiet )    
            }
        }
    }
)

function Main{
    foreach( $local:Action in $Automation ) {
        Invoke-LoggedAction @Action -Quiet -ErrorAction Stop
    }
    $Group = Get-MgGroup -Filter "DisplayName eq 'Varonis Assignment Group'"

    foreach( $local:i in @(1..20) ) {
        $local:UserName = "Test User {0:D2}" -f $i
        try {
            $local:CreateNewUserAction = @{
                Operation="Create User"
                Description="$UserName"
                Action={param([LogEntry]$log,$Quiet,$more)
                    $UserName=$more[0]
                    $local:User = Get-MgUser -Filter "DisplayName eq '$UserName'"
                        
                    if( $User ) {
                        $log.UpdateLogEntry($true, "User '$UserName' already exists $($User.Id)", $Quiet )
                    } else {
                        $NewUser = @{
                            AccountEnabled = $true
                            DisplayName = $UserName
                            MailNickname = $UserName -replace ' ','.'
                            UserPrincipalName = "$($UserName -replace ' ','.')@$script:Domain"
                            PasswordProfile = @{
                                ForceChangePasswordNextSignIn = $true
                                Password = "MyP@ssw0rd!"
                            }
                        }
                        
                        # Create the user
                        $User = New-MgUser @NewUser -ErrorAction Stop
                        $log.UpdateLogEntry($true, "User '$UserName' created $($User.Id)", $Quiet )
                    }

                    $User
                }
            }        
            $local:User = Invoke-LoggedAction @CreateNewUserAction $UserName -Quiet

            $local:AddUserToGroup = @{
                Operation="Add User to Group: $($Group.DisplayName)"
                Description="$UserName"
                Action={param([LogEntry]$log,$Quiet,$more)
                    $Group=$more[0]
                    $User=$more[1]
                    $UserName = $User.DisplayName
                    $GroupName = $Group.DisplayName

                    $Groups = Get-MgUserMemberOf -UserId $User.Id | Where-Object Id -eq $Group.Id
                    
                    if( $Groups ) {
                        $log.UpdateLogEntry($true, "User '$UserName' already a member of $GroupName", $Quiet )
                    } else {
                        $AssignGroupMember = @{
                            GroupId=$Group.Id
                            DirectoryObjectId=$User.Id
                        }
                        
                        # Create the user
                        $User = New-MgGroupMember @AssignGroupMember -ErrorAction Stop
                        $log.UpdateLogEntry($true, "Success", $Quiet )
                    }
                }
            }                
            Invoke-LoggedAction @AddUserToGroup $Group $User $User.Id $User.DisplayName -Quiet
        } catch {
            # In case of error, continue to the next user.
        }
    }    
}

try {
    Main     
} catch {
    # We are relying on the LogTrail to show us any problems.
}
finally {
    Write-Host -ForegroundColor Cyan "Run complete, reprinting complete log:"
    $LogTrail.logs | Format-Table -Wrap
}