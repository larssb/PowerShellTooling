####################
# FUNCTION - PREP #
####################
##Requires -

####################
# FUNCTION - START #
####################
function get-environmentOS() {
<#
.DESCRIPTION
    Long description
.INPUTS
    Inputs (if any)
.OUTPUTS
    Outputs (if any)
.NOTES
    General notes
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
#>

    #############
    # Execution #
    #############
    $osType = [Environment]::OSVersion.Platform;

    # Return
    $osType;
}
##################
# FUNCTION - END #
##################