function Set-xScheduledTask() {
<#
.DESCRIPTION
    Configures the username:password combo on a Scheduled task.
.INPUTS
    [CimInstance] representing the Scheduled task to configure.
    [String] one for the password and another for the username.
.OUTPUTS
    [Boolean] relative to the result of configuring the scheduled task.
.NOTES
    <none>
.EXAMPLE
    $result = Set-xScheduledTask -InputObject $task -UserName "HealOps" -Password "MyNotSoSecretPassword"
        > Calls Set-xScheduledTask in order to configure the username:password combo on the Scheduled task in -InputObject.
.PARAMETER InputObject
    A CimInstance Scheduled Task object.
.PARAMETER Password
    A cleartext password to set on the a scheduled task.
.PARAMETER UserName
    The name of the user on the task to configure.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Boolean])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingUserNameAndPassWordParams","")]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A CimInstance Scheduled Task object.")]
        [ValidateNotNullOrEmpty()]
        [CimInstance]$InputObject,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A cleartext password to set on the scheduled task.")]
        [ValidateNotNullOrEmpty()]
        [String]$Password,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The name of the user on the task to configure.")]
        [ValidateNotNullOrEmpty()]
        [String]$UserName
    )

    #############
    # Execution #
    #############
    Begin {
        <#
            - Variables
        #>
        $result = $false # Semaphore
    }
    Process {
        if ($null -ne (Get-Module -Name ScheduledTasks -ListAvailable) ) {
            # ScheduledTasks PowerShell module
            try {
                Set-ScheduledTask -InputObject $InputObject -Password $Password -User $UserName -ErrorAction Stop
                $result = $true
            } catch {
                throw "Set-xScheduledTask > Did not successfully set the password on the job. Failed with > $_"
            }
        } else {
            # SCHTASKS
            throw "schtasks is not supported yet...."
        }
    }
    End {
        # Return
        $result
    }
}