#Requires -Modules invokebuild

# Builds the module by invoking invoke-build on the build.invBuild.ps1 script.
Invoke-Build -file $PSScriptRoot\build.invBuild.ps1 -Task Build;