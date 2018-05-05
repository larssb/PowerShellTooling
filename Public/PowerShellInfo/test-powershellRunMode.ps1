##Requires -Version 3
function test-powershellRunMode() {
<#
.DESCRIPTION
    Tests whether PowerShell is running interactively or in headless mode.
.INPUTS
    None
.OUTPUTS
     [String] with a value of interactive or headless.
.NOTES
    Simple function for testnig the mode that a PowerShell environment is in.
.EXAMPLE
    PS C:\> test-powerShellRunMode
    Test whether the current PowerShell session runs in interactive or headless mode.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$false, ParameterSetName="Headless", HelpMessage="Use this switch parameter to specify that you wish to test if the PowerShell execution environment is in headless mode.")]
        [Switch]$Headless,
        [Parameter(Mandatory=$false, ParameterSetName="Interactive", HelpMessage="Use this switch parameter to specify that you wish to test if the PowerShell execution environment is in interactive mode.")]
        [Switch]$Interactive
    )

    #############
    # Execution #
    #############
    $runmode = [Environment]::UserInteractive
    if ($runmode -eq $true) {
        if($Interactive) {
            $result = $true
        } else {
            $result = $false
        }
    } else {
        if ($Interactive) {
            $result = $false
        } else {
            $result = $true
        }
    }

    # Return
    $result
}