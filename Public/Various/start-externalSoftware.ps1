function start-externalSoftware() {
<#
.DESCRIPTION
    Use this function when you want to execute an external program via PowerShell and want to get back the stdout, the stderr and the exitcode streams that the external program
    streamed data into.
    The exitcode stream is available when using the start-process cmdlet. However, the stdout and stderr streams are not. This function can therefore help when you need to get
    those streams. For example when you want to provide more data on the error that made the external program fail.
.INPUTS
    [None]
.OUTPUTS
    A [System.Diagnostics.Process] object.
.NOTES
    Use this function only if the exitcode stream that the start-prcess cmdlet provides is not enough.

    Info from this URI used: https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process
.EXAMPLE
    start-externalSoftware -executableName pandoc -commandArguments "/home/user/file.txt --writer=mediawiki"
.PARAMETER executableName
    The name of the external software executable to be started.
.PARAMETER commandArguments
    The arguments to provide to the external software executable being started.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([System.Diagnostics.Process])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", Scope="Function")] # Not changing system state with this function & want to use the start verb in the function name. As it fits the best.
    param(
        [Parameter(Mandatory=$true, ParameterSetName="default", HelpMessage="The name of the external software executable to be started.")]
        [ValidateNotNullOrEmpty()]
        [string]$executableName,
        [Parameter(Mandatory=$false, ParameterSetName="default", HelpMessage="The arguments to provide to the external software executable being started.")]
        [string]$commandArguments
    )

    #############
    # Execution #
    #############
    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo;
        $pinfo.FileName = $command;
        $pinfo.RedirectStandardError = $true;
        $pinfo.RedirectStandardOutput = $true;
        $pinfo.UseShellExecute = $false;
        $pinfo.Arguments = $commandArguments;
        $p = New-Object System.Diagnostics.Process;
        $p.StartInfo = $pinfo;
        $p.Start() | Out-Null; # Start the process but do not output on it out.

        # Create a PowerShell custom object to annotate the System.Diagnostics.Process object with.
        [pscustomobject]@{
            #commandTitle = $commandTitle
            stdout   = $p.StandardOutput.ReadToEnd();
            stderr   = $p.StandardError.ReadToEnd();
            ExitCode = $p.ExitCode;
        }

        # Must be called after the above .ReadToEnd() calls for stdout and stderr. If not a deadlock situation could occur.
        $p.WaitForExit();
    } catch {
        throw "$_";
    }
}
##################
# FUNCTION - END #
##################