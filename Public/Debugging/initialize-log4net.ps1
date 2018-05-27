function Initialize-Log4Net() {
<#
.SYNOPSIS
    A helper module that assists in initializing and configuring Log4Net. Log4Net is a logging framework developed by Apache.

    - For more info on Log4Net > URI: http://logging.apache.org/log4net/
.DESCRIPTION
    A wrapper around Log4Net, in PowerShell. Providing a practical, and easy way to log exceptions and so forth to disk.
.INPUTS
    [String]Log4NetConfigFile
    [String]LogFileName
    [String]LogFilesPath
    [String]LoggerName
.OUTPUTS
    [log4net.ILog] representing the Log4Net object with which you can log to a file. With the configuration defined and given as input
    to the Log4NetConfigFile parameter.
.NOTES
    - The module returns a log4net logger object. Instantiated with the confguration settings in the xml file.
    - Log4Net will not itself throw an error as it fails silently!

    Made into helper function by: Lars S. B. - bingchonglars@gmail.com - +4527320102
.EXAMPLE
    $log4netLogger = initialize-log4net -log4NetConfigFile $log4NetConfigFile -logfileName $log4netlog -loggerName $log4netLogName -LogFilesPath $LogFilesPath
    > Instantiates log4net with the settings found in the log4NetConfigFile specified. And with a logfilename as in $log4netlog and so forth.
.PARAMETER Log4NetConfigFile
    A fully qualified path to the Log4Net config (XML) file.
.PARAMETER LogFileName
    The name that the log4net logfile should get.
.PARAMETER LogFilesPath
    The path to the directory where logfiles will be written.
.PARAMETER LoggerName
    The name of the logger defined in the log4net config file.
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([Void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Log4NetConfigFile,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LogFileName,
        [Parameter(Mandatory)]
        [String]$LogFilesPath,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LoggerName
    )

#############
# Execution #
#############
    Begin {
        # Import the log4net assembly
        Add-Type -Path $PSScriptRoot/../../Artefacts/log4net/Assemblies/bin/log4net.dll
    }
    Process {
        ####
        # Configure log4Net
        ####
        #
        [log4net.GlobalContext]::Properties["LogFileName"] = "$logFileName.log"

        # TO-DO > Find a way to define the path....maybe something like > https://github.com/LaurentDardenne/Log4Posh/blob/fb421082cbff95b78ff25d96f580f0a6eb3ebf67/src/Log4Posh.psm1#L84

        $logRepository = [log4net.LogManager]::GetRepository([System.Reflection.Assembly]::GetEntryAssembly())
        [log4net.Config.XmlConfigurator]::ConfigureAndWatch($logRepository,(Get-Item $log4NetConfigFile))

        # Instantiate a log4Net logger that will base its settings on the config in the provided .xml file
        $log4NetLogger = [log4net.logmanager]::GetLogger($logRepository.Name,"$loggerName")
    }
    End {
        # Return the logger to caller
        $log4NetLogger
    }
}