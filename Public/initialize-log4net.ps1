function initialize-log4net() {
<#
.SYNOPSIS
    Helper module that assists in initializing and configuring the log4net assembly. Log4Net is a logging framework.
    Developed by Apache.
    URI: http://logging.apache.org/log4net/

    Made into helper function by: Lars S. B. - bingchonglars@gmail.com - +4527320102
.DESCRIPTION
    This helper function provides a practical way to log exceptions and so forth to the filesystem.
.PARAMETER log4NetConfigFile
    A fully qualified path to the Log4Net config (XML) file.
.PARAMETER LogFilesPath
    The path to the directory where logfiles will be written.
.PARAMETER logfileName
    The name that the log4net logfile should get.
.PARAMETER loggerName
    The name of the logger defined in the log4net config file.
.NOTES
    - The module expects that you configure log4net via an xml file. Use the provided template as a startingpoint. Found in the "config" folder.
        -- You can configure several loggers in the xml file. Call the one you want. It could e.g. be one with LEVEL DEBUG or one with LEVEL ERROR.
    - The module returns a log4net logger object. Instantiated with the confguration settings in the xml file.
    - Log4Net will not itself throw an error as it fails silently!
.EXAMPLE
    $log4netLogger = initialize-log4net -log4NetConfigFile $log4NetConfigFile -logfileName $log4netlog -loggerName $log4netLogName -LogFilesPath $LogFilesPath
    > Instantiates log4net with the settings found in the log4NetConfigFile specified. And with a logfilename as in $log4netlog and so forth.
#>

    # Define parameters
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="A fully qualified path to the Log4Net config (XML) file.")]
        [ValidateNotNullOrEmpty()]
        [String]$log4NetConfigFile,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The name that the log4net logfile should get.")]
        [ValidateNotNullOrEmpty()]
        [String]$logFileName,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The path to the directory where logfiles will be written.")]
        [String]$LogFilesPath,
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The name of the logger defined in the log4net config file.")]
        [ValidateNotNullOrEmpty()]
        [String]$loggerName
    )

#############
# Execution #
#############
    # Import the log4net assembly
    Import-Module -Name $PSScriptRoot/../Artefacts/log4net/Assemblies/bin/log4net.dll

    # Get a LogManager
    $log4NetLogManager = [log4net.logmanager]

    # Configure log4Net
    [log4net.GlobalContext]::Properties["LogFileName"] = "$LogFilesPath\$logFileName.log"
    [log4net.Config.XmlConfigurator]::ConfigureAndWatch("$log4NetConfigFile")

    # Instantiate a log4Net logger that will base its settings on the config in the provided .xml file
    $log4NetLogger = $log4NetLogManager::GetLogger($loggerName)

    # Return the logger to caller
    $log4NetLogger
}