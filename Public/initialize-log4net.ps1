
#####################
# FUNCTION - START
#####################
function initialize-log4net() {
<#
.SYNOPSIS
    Helper module that assists in initializing and configuring the log4net assembly. Log4Net is logging software.
    Developed by Apache.
    URI: http://logging.apache.org/log4net/

    Made into helper function by: Lars S. B. - bingchonglars@gmail.com - +4527320102
.DESCRIPTION
    This helper function provides a practical way to log exceptions and so forth to the filesystem.
.PARAMETER log4NetAssemblyPath
    The path of the log4net assembly.
.PARAMETER log4NetFilesPath
    The path where log4net should look for and place files.
.PARAMETER log4NetFilesName
    The filename of the log4net files. File extension is automatically added.
.PARAMETER log4NetLoggerName
    The name of the logger that is defined in the xml log4net config.
.NOTES
    - The module expects that you configure log4net via an xml file. Use the provided template as a startingpoint. Found in the "config" folder.
        -- You can configure several loggers in the xml file. Call the one you want. It could be one with LEVEL DEBUG or one with LEVEL ERROR.
    - The module returns a log4net logger object. Instantiated with the confguration settings in the injected xml file.
    - Log4Net will not itself throw an error, it will fail silently.
.EXAMPLE
    $log4netLogger = initialize-log4net -log4NetAssemblyPath .\initializeLog4Net\log4net\bin\net\4.0\release\log4net.dll -log4NetFilesPath .\initializeLog4Net -log4NetFilesName log4netlog -log4NetLoggerName log4netLogName
#>

    # Define parameters
    param(
        [Parameter(Mandatory=$true, HelpMessage="The path of the log4net assembly.")]
        [ValidateNotNullOrEmpty()]
        $log4NetAssemblyPath,
        [Parameter(Mandatory=$true, HelpMessage="The path where log4net should look for and place files.")]
        [ValidateNotNullOrEmpty()]
        $log4NetFilesPath,
        [Parameter(Mandatory=$true, HelpMessage="The filename of the log4net files. File extension is automatically added.")]
        [ValidateNotNullOrEmpty()]
        $log4NetFilesName,
        [Parameter(Mandatory=$true, HelpMessage="The name of the logger that is defined in the xml log4net config.")]
        [ValidateNotNullOrEmpty()]
        $log4NetLoggerName
    )

####
# Execution
####
    # Import the log4net assembly
    Import-Module -Name $log4NetAssemblyPath;

    # Get a LogManager
    $log4NetLogManager = [log4net.logmanager];

    # Configure log4Net
    [log4net.GlobalContext]::Properties["LogFileName"] = "$log4NetFilesPath\$log4NetFilesName.log";
    [log4net.Config.XmlConfigurator]::ConfigureAndWatch("$log4NetFilesPath\$log4NetFilesName.xml");

    # Instantiate a log4Net logger that will base its settings on the config in the provided .xml file
    $log4NetLogger = $log4NetLogManager::GetLogger($log4NetLoggerName);

    # Return the logger to caller
    $log4NetLogger;
}
###################
# FUNCTION - END
###################