# Include: Settings
Import-Module -name $PSScriptRoot/settings.pester.tests.psm1 -Force;

<#
    -
#>
# Define vars
$moduleName = $($Settings.moduleName);
$moduleRoot = $($Settings.moduleRoot);
Describe "General project validation: $moduleName" {
    $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object {@{file = $_}}
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It "Module '$moduleName' can import cleanly" {
        {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force -ErrorAction Stop } | Should Not Throw
    }
}