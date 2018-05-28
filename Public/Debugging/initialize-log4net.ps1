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
    - The ConfigureAndWatch() is used on the Log4Net XMLConfigurator. That means that the Log4Net XML config file can be changed while the application is running and the changes will be hot-loaded.
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
        # Global setting, the log filename and the path to it. Combined.
        [log4net.GlobalContext]::Properties["LogFileName"] = "$LogFilesPath$logFileName.log"

        # Set up the repository and the XmlConfigurator. In configure and watch mode. Meaning that the config file can be changed and the changes will be hot-loaded.
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