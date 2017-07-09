###################
# FUNCTION - PREP #
###################
#Requires -Version 3

####################
# FUNCTION - START #
####################
function test-powershellRunMode() {
<#
.DESCRIPTION
    Tests whether PowerShell is running interactively or in headless mode.
.INPUTS
    None
.OUTPUTS
     [String] with a value of interactive or headless.
.NOTES
    Simple function.
.EXAMPLE
    PS C:\> test-powerShellRunMode
    Test whether the current PowerShell session runs in interactive or headless mode.
#>

    # Define parameters
    [CmdletBinding()]param()

    #############
    # Execution #
    #############
    $result = [Environment]::UserInteractive;
    if ($result -eq $true) {
        $mode = "interactive";
    } else {
        $mode = "headless";
    }

    # Return the result.
    $mode;
}
##################
# FUNCTION - END #
##################