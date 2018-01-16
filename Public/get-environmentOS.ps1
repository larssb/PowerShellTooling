function get-environmentOS() {
<#
.DESCRIPTION
    Returns the type of OS.
.INPUTS
    <none>
.OUTPUTS
    [String] representing the type of the OS.
.NOTES
    <none>
.EXAMPLE
    $osType = get-environmentOS
        > Returns the type of OS.
#>

    [CmdletBinding()]
    [OutputType([System.String])]

    #############
    # Execution #
    #############
    $osType = [Environment]::OSVersion.Platform

    switch ($osType) {
        "Win32NT" { $type = "Windows" }
        "Unix" { $type = "Linux" }
        Default {
            throw "The OS could not be determined. The value of OS type is > $osType"
        }
    }

    # Return
    $type
}