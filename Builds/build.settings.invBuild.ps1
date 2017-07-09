###############################################################################
# Customize these properties and tasks
###############################################################################
param(
    $Artifacts = "$PSScriptRoot/Artifacts",
    $ModulePath = "$PSScriptRoot/..",
    $BuildNumber = $env:BUILD_NUMBER,
    $PercentCompliance  = '80'
)

###############################################################################
# Static settings -- no reason to include these in the param block
###############################################################################
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$Settings = @{
    Author =  "Lars"
    LicenseUrl = '1'
    ModuleName = Get-Item $ModulePath/*.psd1 | Where-Object { $null -ne (Test-ModuleManifest -Path $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1 | Foreach-Object BaseName
    Owners = "yes"
    PackageDescription = "2222"
    ProjectUrl = "2"
    Repository = '22'
    Tags = "test"

    # TODO: fix any redudant naming
    GitRepo = "fr"
    CIUrl = "fr"
}

###############################################################################
# Before/After Hooks for the Core Task: Clean
###############################################################################

# Synopsis: Executes before the Clean task.
task BeforeClean {}

# Synopsis: Executes after the Clean task.
task AfterClean {}

###############################################################################
# Before/After Hooks for the Core Task: Analyze
###############################################################################

# Synopsis: Executes before the Analyze task.
task BeforeAnalyze {}

# Synopsis: Executes after the Analyze task.
task AfterAnalyze {}

###############################################################################
# Before/After Hooks for the Core Task: Archive
###############################################################################

# Synopsis: Executes before the Archive task.
task BeforeArchive {}

# Synopsis: Executes after the Archive task.
task AfterArchive {}

###############################################################################
# Before/After Hooks for the Core Task: Publish
###############################################################################

# Synopsis: Executes before the Publish task.
task BeforePublish {}

# Synopsis: Executes after the Publish task.
task AfterPublish {}

###############################################################################
# Before/After Hooks for the Core Task: Test
###############################################################################

# Synopsis: Executes before the Test Task.
task BeforeTest {}

# Synopsis: Executes after the Test Task.
task AfterTest {}