function Get-xScheduledTask() {
<#
.DESCRIPTION
    Retrieves a scheduled task on a Windows system. It supports schtasks as well as the ScheduledTasks PowerShell module.
.INPUTS
    Inputs (if any)
.OUTPUTS
    [CimInstance] representing the Scheduled task retrieved.
.NOTES
    <none>
.EXAMPLE
    [CimInstance]$task = Get-xScheduledTask -TaskName "TaskName"
    Explanation of what the example does
.PARAMETER TaskName
    The name of the Scheduled Task to get.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([CimInstance])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The name of the Scheduled Task to get.")]
        [ValidateNotNullOrEmpty()]
        [String]$TaskName
    )

    #############
    # Execution #
    #############
    Begin {}
    Process {
        if ($null -ne (Get-Module -Name ScheduledTasks -ListAvailable) ) {
            # ScheduledTasks PowerShell module
            try {
                $scheduledTask = Get-ScheduledTask -TaskName $TaskName
            } catch {
                throw "Get-xScheduledTask > Failed to get the scheduled task named > $TaskName. Failed with > $_"
            }
        } else {
            # SCHTASKS
            throw "schtasks is not supported yet...."
        }
    }
    End {
        # Return
        $scheduledTask
    }
}