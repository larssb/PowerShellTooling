##Requires -
function get-hostname() {
    <#
    .DESCRIPTION
        Determines the name of the node/host
    .INPUTS
        <none>
    .OUTPUTS
        [String] representing the name of the node/host.
    .NOTES
        General notes
    .EXAMPLE
        get-hostname
        Retrieves and outputs the name of the node/host on which is executed on.
    #>

        #############
        # Execution #
        #############
        $machineName = [Environment]::MachineName

        # Return
        $machineName
    }