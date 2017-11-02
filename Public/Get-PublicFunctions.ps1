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
    $publicFunctions = Get-PublicFunctions -PublicDirectory ./Public

    Gets the files in the ./Public folder >> derives the function name inside each file >> outputs an array that contains the function names.
.EXAMPLE
    $publicFunctions = Get-PublicFunctions -PublicDirectory ./Public
    Update-ModuleManifest -Path ./"MANIFESTFILE.psd1" -FunctionsToExport $publicFunctions

    Gets the files in the ./Public folder >> derives the function name inside each file >> outputs an array that contains the function names.
    The retrieved function names is then used to update a modules manifest file with the Update-ModuleManifest cmdlet.
.PARAMETER PublicDirectory
    The path to the Public directory in a PowerShell module root.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([Array])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The path to the Public directory in a PowerShell module root.")]
        [ValidateNotNullOrEmpty()]
        $PublicDirectory
    )

    #############
    # Execution #
    #############
    <#
        - Verify the path
    #>
    if(-not (Test-Path -Path $PublicDirectory)) {
        Write-Output "Cannot continue as the specified path does not exist."
        break
    }

    if(-not ($PublicDirectory -imatch "public")) {
        Write-Output "Cannot continue. The path you provide should be the 'Public' directory in the root of a PowerShell module"
        break
    }

    <#
        - Get the functions in the PowerShell files in the Public folder
    #>
    $functionsArray = [System.Collections.ArrayList]::new()
    $publicPSFiles = Get-ChildItem -Path $PublicDirectory -Recurse -File

    foreach($file in $publicPSFiles) {
        $ast = [System.Management.Automation.PSParser]::Tokenize( (Get-Content $($file.FullName)), [ref]$null)
        $function = $ast.where( {$_.content -eq "function" -and $_.Type -eq "Keyword"} )

        if($function.count -eq 1) {
            if ($function.startline -le 1) {
                # Handle the situation where the function keyword is on the first line in the file
                $lineOfFunction = (Get-Content -Path $($file.fullname) -TotalCount $($function.startline))
            } else {
                $lineOfFunction = (Get-Content -Path $($file.fullname) -TotalCount $($function.startline))[-1]
            }

            if ($null -ne $lineOfFunction) {
                # Get the function name only
                Write-Verbose "lineOfFunc is: $lineOfFunction"
                $functionName = $lineOfFunction.Substring($function.EndColumn) -replace "\(.+",""

                # Store the function name
                $functionsArray.Add($functionName) | Out-Null
            }
        } else {
            Write-Output "There is more than one function in $($file.fullname). Please fix this. Because of this the file was skipped and it's functions not populated to the modules *.psd1 file"
            break
        }

    }

    # Return the array
    ,$functionsArray
}