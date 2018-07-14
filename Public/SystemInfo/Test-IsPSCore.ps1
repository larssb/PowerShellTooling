function Test-IsPSCore() {
<#
.DESCRIPTION
    Tests whether the PowerShell runtime environment is PS Core.
.INPUTS
    <none>
.OUTPUTS
    [Bool] representing the result of testing whether the PowerShell runtime environment is PS Core.
.NOTES
    <none>
.EXAMPLE
    PS C:\> [Bool]$Result = Test-IsPSCore
    Invokes Test-IsPSCore to determine whether the PowerShell runtime environment is PS Core.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Bool])]
    param()

    #############
    # Execution #
    #############
    Begin {}
    Process {
        [Bool]$Result = $PSVersionTable.PSEdition -ieq 'core'
    }
    End {
        # Return the
        $Result
    }
}