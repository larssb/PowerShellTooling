function Set-xScheduledTask() {
<#
.DESCRIPTION
    Long description
.INPUTS
    Inputs (if any)
.OUTPUTS
    [Boolean] relative to the result of setting
.NOTES
    General notes
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.PARAMETER InputObject
    A CimInstance Scheduled Task object.
.PARAMETER Password
    A cleartext password to set on the a scheduled task.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Boolean])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A CimInstance Scheduled Task object.")]
        [ValidateNotNullOrEmpty()]
        [CimInstance]$InputObject,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A cleartext password to set on the a scheduled task.")]
        [ValidateNotNullOrEmpty()]
        [String]$Password
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
                Set-ScheduledTask -InputObject $InputObject -Password $Password
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