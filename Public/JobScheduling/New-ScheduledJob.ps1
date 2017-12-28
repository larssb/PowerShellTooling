function New-ScheduledJob() {
<#
.DESCRIPTION
    Handles the necessities for a Windows Scheduled task to be created. When creatd with this function it will be a job of the type >
    'Windows PowerShell scheduled jobs' which are a hybrid of 'Windos PowerShell background jobs' and 'Task Scheduler tasks'.
.INPUTS
    Inputs (if any)
.OUTPUTS
    <nothing>
.NOTES
    # It will only be possible to see the scheduled job in the 'Task Scheduler' with an administrator user.
    # The scheduled job will be stored in > $env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ScheduledJobs
        ## Relative to the administrator by which you create the job.
    # The scheduled job output will be to a Results.xml and a Status.xml file. They are stored under > $env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ScheduledJobs\"NAME_OF_THE_SCHEDULED_JOB"\Output\"DATE_TIME_NAMED_FOLDER"\*
.EXAMPLE
    New-ScheduledJob -TaskName $TaskName
    Explanation of what the example does
.PARAMETER TaskName
    The name that the Scheduled task should have.
.PARAMETER TaskOptions
    A hashtable, for splatting, containing the options you want the job to have.
.PARAMETER TaskTriggerOptions
    A hashtable, for splatting, containing the options you want the job trigger to have.
.PARAMETER TaskPayload
    A dynamic parameter for specifying the payload a Windows Scheduled Task should have when triggered. It can be either a file path to a script file or a scriptblock object.
.PARAMETER credential
    The credential of the user that should execute the HealOps task.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Void])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The name that the Scheduled task should have.")]
        [ValidateNotNullOrEmpty()]
        [String]$TaskName,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A hashtable, for splatting, containing the options you want the job to have.")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$TaskOptions,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A hashtable, for splatting, containing the options you want the job trigger to have.")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$TaskTriggerOptions,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The type of payload the task should execute when triggered.")]
        [ValidateSet('File','ScriptBlock')]
        [String]$TaskPayload,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The credentials of the user that should execute the HealOps task.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$credential
    )

    DynamicParam {
        <#
            - General config for the FilePath or Scriptblock parameter relative to the TaskPayload value.
        #>
        # Configure parameter
        $attributes = new-object System.Management.Automation.ParameterAttribute
        $attributes.Mandatory = $true
        $ValidateNotNullOrEmptyAttribute = New-Object Management.Automation.ValidateNotNullOrEmptyAttribute
        [Type]$ParameterType = "String"

        # Define parameter collection
        $attributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)
        $attributeCollection.Add($ValidateNotNullOrEmptyAttribute)

        # Specific config
        if($TaskPayload -eq "File") {
            $attributes.HelpMessage = "The full path to the file that the Windows Scheduled Task should execute when triggered."
            $ParameterName = "FilePath"
        } elseif($TaskPayload -eq "ScriptBlock") {
            $attributes.HelpMessage = "The scriptblock that the scheduled task should execute when triggered."
            $ParameterName = "ScriptBlock"
        }

        # Prepare to return & expose the parameter
        $Parameter = New-Object Management.Automation.RuntimeDefinedParameter($ParameterName, $ParameterType, $AttributeCollection)
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add($ParameterName, $Parameter)
        return $paramDictionary
    }

    #############
    # Execution #
    #############
    Begin{}
    Process{
        <#
            - Prepare scheduled job configuration data
        #>
        # Job trigger
        try {
            $newJobTrigger = New-JobTrigger @TaskTriggerOptions -Verbose
        } catch {
            throw "Defining a job trigger failed with: $_"
        }

        # Job options
        try {
            $newScheduledJobOption = New-ScheduledJobOption @TaskOptions
        } catch {
            throw "Setting job options failed with: $_"
        }

        <#
            - Job creation
        #>
        # Splatting
        $createJobSplatting = @{}
        $createJobSplatting.Add('Name',$TaskName)
        $createJobSplatting.Add('Trigger',$newJobTrigger)
        $createJobSplatting.Add('ScheduledJobOption',$newScheduledJobOption)
        $createJobSplatting.Add('Credential',$credential)
        if ($TaskPayload -eq 'File') {
            # Add the FilePath specific parameter to the splatting collection
            $createJobSplatting.Add('FilePath',$psboundparameters.FilePath)
        } else {
            # Add the FilePath specific parameter to the splatting collection
            $ScriptBlockObject = [System.Management.Automation.ScriptBlock]::Create($psboundparameters.ScriptBlock)
            $createJobSplatting.Add('ScriptBlock',$ScriptBlockObject)
        }

        # Create the scheduled job
        try {
            Register-ScheduledJob -InitializationScript { $currentExecPolicy = Get-ExecutionPolicy -Scope CurrentUser; if($currentExecPolicy -ne "ByPass") { Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force | Out-Null } } @createJobSplatting -ErrorAction Stop | out-null

            # Status of the job creation
            $runMode = test-powershellRunMode -Interactive
            if($runMode) {
                write-host "The job was created successfully" -ForegroundColor Green
            }
        } catch {
            #
            throw "Failed to create the job. Failed with: $_"
        }
    }
    End{}
}