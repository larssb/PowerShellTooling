function Add-ScheduledTask() {
<#
.DESCRIPTION
    Creates a Windows Scheduled Task either via the schtasks classic cmd or the PowerShell ScheduledTasks module.
.INPUTS
    - [Hashtable] with values for defining a Scheduled Tasks trigger.
    - [Hashtable] with values for defining a Scheduled Tasks settings set.
    - [String] representing the name the created Schedul Task should have.
    - [String] representing the method to be used when creating the task.
.OUTPUTS
    <nothing>
.NOTES
    - You should determine if schtasks or the ScheduledTasks PowerShell module should be used prior to calling this function.
    - Notice! This function will create an action that executes PowerShell with a scriptblock to be invoked via the -Command parameter.
.EXAMPLE
    Add-ScheduledTask -TaskName $TaskName -TaskOptions $Options -TaskTrigger $Trigger -Method "ScheduledTasks"
    Calls this function telling it to use the PowerShell ScheduledTasks module to create a scheduled task.
.PARAMETER Method
    If the task should be created via the classic schtasks cmd or via the ScheduledTasks PowerShell module.
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
        [String]$TaskName,
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
            <#
                - Prepare configuration data for the Scheduled Task
            #>
            # Scheduled Task trigger
            try {
                $newTaskTrigger = New-ScheduledTaskTrigger @TaskTrigger -ErrorAction Stop -Verbose
            } catch {
                throw "Creating a task trigger object failed with: $_"
            }

            <#
                - Scheduled Task options
            #>
            # Splatting
            $createTaskOptionsSplatting = @{}
            $createTaskOptionsSplatting.Add('AllowStartIfOnBatteries', $TaskOptions.AllowStartIfOnBatteries)
            $createTaskOptionsSplatting.Add('DontStopIfGoingOnBatteries', $TaskOptions.DontStopIfGoingOnBatteries)
            $createTaskOptionsSplatting.Add('DontStopOnIdleEnd', $TaskOptions.DontStopOnIdleEnd)
            $createTaskOptionsSplatting.Add('MultipleInstances', $TaskOptions.MultipleInstances)
            $createTaskOptionsSplatting.Add('StartWhenAvailable', $TaskOptions.StartWhenAvailable)
            try {
                $newTaskOptions = New-ScheduledTaskSettingsSet @createTaskOptionsSplatting -ErrorAction Stop -Verbose
            } catch {
                throw "Creating a task options object failed with: $_"
            }

            # Scheduled Task action
            try {
                $newTaskAction = New-ScheduledTaskAction -Execute "$PSHOME\powershell.exe" -Argument "-NoLogo -NonInteractive -WindowStyle Hidden -Command `"$($TaskOptions.PowerShellExeCommand)`"" -Verbose
            } catch {
                throw "Creating a task action object failed with: $_"
            }

            <#
                - Task creation
            #>
            # Splatting
            $createTaskSplatting = @{}
            $createTaskSplatting.Add('Action', $newTaskAction)
            $createTaskSplatting.Add('Password', $TaskOptions.Password)
            $createTaskSplatting.Add('RunLevel', $TaskOptions.RunLevel)
            $createTaskSplatting.Add('Settings', $newTaskOptions)
            $createTaskSplatting.Add('TaskName', $TaskName)
            $createTaskSplatting.Add('Trigger', $newTaskTrigger)
            $createTaskSplatting.Add('User', $TaskOptions.User)

            # Create the scheduled task
            try {
                Register-ScheduledTask @createTaskSplatting -ErrorAction Stop | Out-Null

                # Status of the job creation
                $runMode = test-powershellRunMode -Interactive
                if($runMode) {
                    write-host "The task was created successfully" -ForegroundColor Green
                }
            } catch {
                throw "Failed to create the task. Failed with: $_"
            }
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