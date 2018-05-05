function Get-PSProgramFilesModulesPath() {
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
    $psProgramFilesModulesPath = Get-PSProgramFilesModulesPath
    > Returns the path to the Windows systems PowerShell program files modules directory to caller.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([String])]
    param()

    #############
    # Execution #
    #############
    Begin {}
    Process {
        $IsInbox = $PSHOME.EndsWith('\WindowsPowerShell\v1.0', [System.StringComparison]::OrdinalIgnoreCase)
        if($IsInbox) {
            $ProgramFilesPSPath = Microsoft.PowerShell.Management\Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell"
        } else {
            $ProgramFilesPSPath = $PSHome
        }
        $ProgramFilesModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $ProgramFilesPSPath -ChildPath "Modules"
    }
    End {
        # Return
        [String]$ProgramFilesModulesPath
    }
}