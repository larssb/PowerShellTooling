function Get-PSModulesPath() {
<#
.DESCRIPTION
    Returns the path to the Windows systems PowerShell program files modules directory to caller.
.INPUTS
    <none>
.OUTPUTS
    [String] representing the path to the Windows systems PowerShell program files modules directory.
.NOTES
    - Not system autonomous. Windows specific.
.EXAMPLE
    $PSModulesPath = Get-PSModulesPath
    > Returns the PowerShell modules path to caller.
.PARAMETER Level
    Used to specify the scope/context level you want the PSModulePath to be relative to.
    > Global: The function will return the systemwide PowerShell module folder path.
    > User: The ~ (user home folder) level PowerShell module folder path is returned.
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([String])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Global','User')]
        [String]$Level
    )

    #############
    # Execution #
    #############
    Begin {
        $IsInbox = $PSHOME.EndsWith('\WindowsPowerShell\v1.0', [System.StringComparison]::OrdinalIgnoreCase)
        $IsWindows = (-not (Get-Variable -Name IsWindows -ErrorAction Ignore)) -or $IsWindows
    }
    Process {
        if ($Level -eq "Global") {
            if($IsInbox) {
                $PSPath = Microsoft.PowerShell.Management\Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell"
            } else {
                $PSPath = $PSHome
            }
        } else {
            # User level defined. Set to the PS modules folder underneath the ~/home folder of the calling user context.
            if($IsInbox) {
                try {
                    $MydocsPath = [Environment]::GetFolderPath("MyDocuments")
                } catch {
                    $MydocsPath = $null
                }

                $PSPath = if($MydocsPath) {
                            Microsoft.PowerShell.Management\Join-Path -Path $MydocsPath -ChildPath "WindowsPowerShell"
                        } else {
                            Microsoft.PowerShell.Management\Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell"
                        }
            } elseif($IsWindows) {
                $MydocsPath = [Environment]::GetFolderPath("MyDocuments")
                $PSPath = Microsoft.PowerShell.Management\Join-Path -Path $MydocsPath -ChildPath 'PowerShell'
            } else {
                # We are on a Unix/Linux box.
                $PSPath = Microsoft.PowerShell.Management\Join-Path -Path $HOME -ChildPath ".local/share/powershell"
            }
        }

        # Resolve to the PSModulePath to hand back to caller.
        $PSModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $PSPath -ChildPath "Modules"
    }
    End {
        # Return
        [String]$PSModulesPath
    }
}