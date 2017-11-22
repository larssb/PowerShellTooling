# Log4Net ReadMe

## Usage

    * Code example (so when the function has been executed and a log4net logger object received):
    `
        #
        $log4NetFilesName = "zendeskIntegration_Ps";
        $log4NetLoggerName = "PsZendeskIntegration_Errors";
        $log4NetLoggerNameDebug = "PsZendeskIntegration_Debugs"

        # Initiate log4net logger
        $global:log4netLogger = initialize-log4net -log4NetAssemblyPath $PSScriptRoot\..\log4Net\bin\net\4.0\release\log4net.dll -log4NetFilesPath $PSScriptRoot\..\log4net -log4NetFilesName $log4NetFilesName -log4NetLoggerName $log4NetLoggerName;
        $global:log4netLoggerDebug = initialize-log4net -log4NetAssemblyPath $PSScriptRoot\..\log4Net\bin\net\4.0\release\log4net.dll -log4NetFilesPath $PSScriptRoot\..\log4net -log4NetFilesName $log4NetFilesName -log4NetLoggerName $log4NetLoggerNameDebug;

        # Log something....
        $log4netLoggerDebug.debug("-------------------------------------------------------------");
    `