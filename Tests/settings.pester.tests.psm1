# Private variables
$ModulePath = "$PSScriptRoot/..";

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$Settings = @{
    moduleName = Get-Item $ModulePath/*.psd1 | Where-Object { $null -ne (Test-ModuleManifest -Path $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1 | Foreach-Object BaseName
    moduleRoot = Resolve-Path "$PSScriptRoot\.."
}

Export-ModuleMember -Variable Settings;