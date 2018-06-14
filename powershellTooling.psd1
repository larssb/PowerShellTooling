@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'PowerShellTooling.psm1'

    # ID used to uniquely identify this module
    GUID = 'c1e187cd-222f-4df6-8238-88f90f0284ee'

    # Version number of this module.
    ModuleVersion = '0.0.15'

    # Author of this module
    Author = 'Lars S. Bengtsson | https://github.com/larssb | https://bengtssondd.it'

    # Company or vendor of this module
    CompanyName = 'Bengtsson Driven Development'

    # Copyright statement for this module
    Copyright = '(C) 2018, Lars S. Bengtsson, licensed under Apache 2.0 License.'

    # Description of the functionality provided by this module
    Description = 'A project containing helper functions and other utilities to make your life programming PowerShell easier.'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        "PSSlack"
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Add-ScheduledTask'
        'get-environmentOS'
        'get-hostname'
        'Get-PSProgramFilesModulesPath'
        'Get-PublicFunctions'
        'Get-xScheduledTask'
        'initialize-log4net'
        'New-ScheduledJob'
        'out-functionHierarchy'
        'Set-xScheduledTask'
        'start-externalSoftware'
        'test-powershellRunMode'
        'import-jsonFile'
        'Send-Info'
        )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = False

            # External dependent modules of this module
            # ExternalModuleDependencies = ''

        }
    }
}
