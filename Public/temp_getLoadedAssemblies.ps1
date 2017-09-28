function Get-type {
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Pattern
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

    [CmdletBinding()]
    param (
        [string]$Pattern = '.'
    )

    ####
    # Execution
    ####
    [System.AppDomain]::CurrentDomain.GetAssemblies() | Sort-Object FullName | ForEach-Object {
        $asm = $psitem

        Write-Verbose $asm.Fullname

        switch ($asm.Fullname) {
            {$_ -like 'Anonymously Hosted DynamicMethods Assembly*'} {
                break
            }
            {$_ -like 'Microsoft.PowerShell.Cmdletization.GeneratedTypes*'} {
                break
            }
            {$_ -like 'Microsoft.Management.Infrastructure. UserFilteredExceptionHandling*'} {
                break
            }
            {$_ -like 'Microsoft.GeneratedCode*'} {
                break
            }
            {$_ -like 'MetadataViewProxies*'} {
                break
            }
            default {
                $asm.GetExportedTypes() |
                Where-Object {$_ -match $Pattern} |
                Select-Object @{N='Assembly';
                E={($_.Assembly -split ',')[0]}},
                IsPublic, IsSerial,FullName, BaseType
            }
        }
    }
}