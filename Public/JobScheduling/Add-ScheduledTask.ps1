function Add-ScheduledTask() {
<#
.DESCRIPTION
    Long description
.INPUTS
    Inputs (if any)
.OUTPUTS
    <nothing>
.NOTES
    General notes
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.PARAMETER TaskName
    The name that the Scheduled task should have.
.PARAMETER TaskOptions
    A hashtable, containing the options you want the job to have.
.PARAMETER TaskTrigger
    A hashtable, containing the options you want the job trigger to have.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Void])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The name that the Scheduled task should have.")]
        [ValidateNotNullOrEmpty()]
        $TaskName,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A hashtable, containing the options you want the job to have.")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$TaskOptions,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A hashtable, containing the options you want the job trigger to have.")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$TaskTrigger,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="If the task should be created via the classic schtasks cmd or via the ScheduledTasks PowerShell module.")]
        [ValidateSet('ScheduledTasks','schtasks')]
        [String]$Method
    )

    #############
    # Execution #
    #############
    Begin {}
    Process {
        if ($Method -eq "ScheduledTasks") {

        } else {
            <#
                - Set the arguments for the schtasks commando
                    -- In depth explanation of the args
                    > /Create == Specifies that we want to create a scheduled task.
                    > /TN taskname == The name of the scheduled task.
                    > /TR executable == The name of the executable to call when running the task.
                    > /RU username == Specifies the Run-As account name for the task.
                    > /RP password == Specifies the Run-As account password for the task.
                    > /RL HIGHEST == Specifies the run-level of the task.
                    > /SC MINUTE == Tells schtasks that the task should be repeated at a minute interval.
                    > /MO repetition interval == Tells schtasks that the repetition should be set to the incoming value of the TaskTrigger.RepetitionIntervalSchtasks.
            #>
            [Array]$argsArray = "/Create", "/TN $TaskName", "/TR $($TaskOptions.ToRun)", "/RU $($TaskOptions.Username)", "/RP $($TaskOptions.Password)", "/RL HIGHEST", "/SC MINUTE", "/MO $($TaskTrigger.RepetitionInterval)"

            # Use the built-in schtasks commando to create the scheduled task
            try {
                Start-Process -FilePath schtasks -ArgumentList $argsArray -NoNewWindow -Wait -ErrorAction Stop
            } catch {
                throw "schtasks failed with > $_"
            }
        }
    }
    End {}
}