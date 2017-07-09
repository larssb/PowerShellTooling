#Requires -Modules Pester
Invoke-Pester -Script $PSScriptRoot\psSyntaxAndImportValidation.pester.tests.ps1 -EnableExit;