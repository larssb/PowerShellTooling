##Requires -

function Get-PublicFunctions() {
<#
.DESCRIPTION
    Derives the functions in all files inside the "Public" directory of a PowerShell module.

    AXIOMS:
        - Assumes that you use a PowherShell module structure:
            > ModuleRoot
                >> Public
                >> Private
                >> "F" folder....
        - The files in the Public folder only have one function defined in them.
        - The files in the Public folder is really files that contains functions you want exported in a *.psd1/manifest file.
.INPUTS
    <none>
.OUTPUTS
    [Array] of public functions to export. For example to a *.psd1/manifest file.
.NOTES
    General notes
.EXAMPLE
    Get-PublicFunctions
    Explanation of what the example does
.PARAMETER pathPublicDirectory
    The path to the Public directory in a PowerShell module root.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Array])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The path to the Public directory in a PowerShell module root.")]
        [ValidateNotNullOrEmpty()]
        $pathPublicDirectory
    )

    #############
    # Execution #
    #############
    <#
        - Verify the path
    #>
    if(-not (Test-Path)) {
        Write-Information -MessageData "Cannot continue as the specified path does not exist."
        break
    }

    if(-not ($pathPublicDirectory -imatch "public")) {
        Write-Information -MessageData "Cannot continue. The path you provide should be the 'Public' directory in the root of a PowerShell module"
        break
    }

    <#
        - Get the functions in the PowerShell files in the Public folder
    #>
    $publicPSFiles = Get-ChildItem -Path $pathPublicDirectory -Recurse -File

    foreach($file in $publicPSFiles) {
        $ast = [System.Management.Automation.PSParser]::Tokenize( (Get-Content $($file.FullName)), [ref]$null)
        $funcKeywords = $ast.where( {$_.content -eq "function" -and $_.Type -eq "Keyword"} )

        if($funcKeywords.count -eq 1) {
            $lineOfFunction = (Get-Content -Path $($file.fullname) -TotalCount $ast.startline)[-1]

            $lineOffunction
        } else {
            Write-Information -MessageData "There is more than one function in $($file.fullname). Please fix this. Because of this the file was skipped and it's functions not populated to the modules *psd1 file"
            break
        }

    }

    # Return the array
    #,

}