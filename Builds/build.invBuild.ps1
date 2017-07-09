# Include: Settings
. './build.settings.invBuild.ps1'

# Include: build utils
. './build.utils.invBuild.ps1'

# Synopsis: Run/Publish Tests and Fail Build on Error
task Test BeforeTest, RunTests, ConfirmTestsPassed, AfterTest

# Synopsis: Run full Pipeline.
task . Clean, Analyze, Test, Archive, Publish

# Synopsis: Install Build Dependencies
task InstallDependencies {
    # Cant run an Invoke-Build Task without Invoke-Build.
    Install-Module -Name InvokeBuild -Force

    Install-Module -Name DscResourceTestHelper -Force
    Install-Module -Name Pester -Force
    Install-Module -Name PSScriptAnalyzer -Force
}

# Synopsis: Clean Artifacts Directory
task Clean BeforeClean, {
    if(Test-Path -Path $Artifacts)
    {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force

    # Temp
    & git clone https://github.com/Xainey/PSTestReport.git
}, AfterClean

# Synopsis: Lint Code with PSScriptAnalyzer
task Analyze BeforeAnalyze, {
    $scriptAnalyzerParams = @{
        Path = $ModulePath
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    # Save Analyze Results as JSON
    $saResults | ConvertTo-Json | Set-Content (Join-Path $Artifacts "ScriptAnalysisResults.json")

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}, AfterAnalyze

# Synopsis: Test the project with Pester. Publish Test and Coverage Reports
task RunTests {
    <#$invokePesterParams = @{
        OutputFile =  (Join-Path $Artifacts "TestResults.xml")
        OutputFormat = 'NUnitXml'
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;

    # Save Test Results as JSON
    $testresults | ConvertTo-Json -Depth 5 | Set-Content  (Join-Path $Artifacts "PesterResults.json")

    # Temp: Publish Test Report
    $options = @{
        BuildNumber = $BuildNumber
        GitRepo = $Settings.GitRepo
        GitRepoURL = $Settings.ProjectUrl
        CiURL = $Settings.CiURL
        ShowHitCommands = $true
        Compliance = ($PercentCompliance / 100)
        ScriptAnalyzerFile = (Join-Path $Artifacts "ScriptAnalyzerResults.json")
        PesterFile =  (Join-Path $Artifacts "PesterResults.json")
        OutputDir = "$Artifacts"
    }

    . ".\PSTestReport\Invoke-PSTestReport.ps1" @options#>

    # TESTING
    $moduleRoot = Resolve-Path "$BuildRoot\.."
    $moduleName = Split-Path $moduleRoot -Leaf

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
            {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
        }
    }
}

# Synopsis: Throws and error if any tests do not pass for CI usage
task ConfirmTestsPassed {
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml] $xml = Get-Content (Join-Path $Artifacts "TestResults.xml")
    $numberFails = $xml."test-results".failures
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

    # Fail Build if Coverage is under requirement
    $json = Get-Content (Join-Path $Artifacts "PesterResults.json") | ConvertFrom-Json
    $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert($OverallCoverage -gt $PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f $overallCoverage, $PercentCompliance)
}

# Synopsis: Creates Archived Zip and Nuget Artifacts
task Archive BeforeArchive, {
    $moduleInfo = @{
        ModuleName = $ModuleName
        BuildNumber = $BuildNumber
    }

    Publish-ArtifactZip @moduleInfo

    $nuspecInfo = @{
        packageName = $ModuleName
        author =  $Settings.Author
        owners = $Settings.Owners
        licenseUrl = $Settings.LicenseUrl
        projectUrl = $Settings.ProjectUrl
        packageDescription = $Settings.PackageDescription
        tags = $Settings.Tags
        destinationPath = $Artifacts
        BuildNumber = $BuildNumber
    }

    Publish-NugetPackage @nuspecInfo
}, AfterArchive

# Synopsis: Publish to SMB File Share
task Publish BeforePublish, {
    $moduleInfo = @{
        RepoName = $Settings.SMBRepoName
        RepoPath = $Settings.SMBRepoPath
        ModuleName = $ModuleName
        ModulePath = "$ModulePath\$ModuleName.psd1"
        BuildNumber = $BuildNumber
    }

    Publish-SMBModule @moduleInfo -Verbose
}, AfterPublish