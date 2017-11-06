##Requires -

function New-ScheduledJob() {
<#
.DESCRIPTION
    Handles the necessities for a Windows Scheduled task to be created. When creatd with this function it will be a job of the type >
    'Windows PowerShell scheduled jobs' which are a hybrid of 'Windos PowerShell background jobs' and 'Task Scheduler tasks'.
.INPUTS
    Inputs (if any)
.OUTPUTS
    [Boolean] relative to the outcome of creating the Windows Scheduled task.
.NOTES
    General notes
.EXAMPLE
    New-ScheduledJob -JobName
    Explanation of what the example does
.PARAMETER JobName
    The name that the Scheduled task should have.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([SPECIFY_THE_RETURN_TYPE_OF_THE_FUNCTION_HERE])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The name that the Scheduled task should have.")]
        [ValidateNotNullOrEmpty()]
        [String]$TaskName,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A hashtable, for splatting, containig the options you want the job to have.")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$TaskOptions,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A hashtable, for splatting, containig the options you want the job trigger to have.")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$TaskTriggerOptions,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The type of payload the task should execute when triggered.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('File','ScriptBlock')]
        [String]$TaskPayload
    )

    #############
    # Execution #
    #############
    <#
        - Prepare scheduled job configuration data
    #>
    # Job trigger
    try {
        $newJobTrigger = New-JobTrigger @TaskTriggerOptions
    } catch {
        Write-Verbose -Message "Defining a job trigger failed with: $_"
    }

    # Job options
    try {
        $newScheduledJobOption = New-ScheduledJobOption @TaskOptions
    } catch {
        Write-Verbose -Message "Setting job options failed with: $_"
    }

    <#
        - Job creation
    #>
    # Create the job
    try {
        # Splatting
        $createJobSplatting = @{}
        if ($TaskPayload -eq 'File') {
            $createJobSplatting.Add('FilePath',)
        }
        Register-ScheduledJob -Name $TaskName -ScriptBlock {Get-Process} -Trigger $newJobTrigger -ScheduledJobOption $newScheduledJobOption

        # Administrators group member creds required if > -RunElevated used.
    } catch {
        Write-Verbose -Message "Creating the job failed with: $_"
    }

    #

}