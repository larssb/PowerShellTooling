# Include: Settings
Import-Module -name $PSScriptRoot/settings.pester.tests.psm1 -Force

# Define the folders to look through
$functionFolders = @('Private', 'Public')

# Define vars
$moduleName = $($Settings.moduleName)
$moduleRoot = $($Settings.moduleRoot)
Describe "General project validation: $moduleName" {
    ForEach ($folder in $functionFolders) {
        $folderPath = Join-Path -Path $moduleRoot -ChildPath $folder
        $scripts = Get-ChildItem $folderPath -Include *.ps1, *.psm1, *.psd1 -Recurse

        if ($null -ne $scripts) {
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
        }
    }

    It "Module '$moduleName' can import cleanly" {
        {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force -ErrorAction Stop } | Should Not Throw
    }
}