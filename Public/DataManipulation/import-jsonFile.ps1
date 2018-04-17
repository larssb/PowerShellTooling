function import-jsonFile() {
<#
.DESCRIPTION
    Imports a JSON file. For example useful whenever you use a JSON file to hold application configuration data. The imported JSON file will be returned as a PSCustomObject making it possible to efficiently
    do further work with the file. As the properties in JSON will be made into properties understood by PowerShell.
.INPUTS
    > The path to the JSON file.
.OUTPUTS
    The imported JSON file. Represented as a PSCustomObject object.
.NOTES
    > Any exceptional errors are 'thrown'. So in the code of yours, utilizing this function, YOU should do the catching.
    > The file should be of type JSON.
.PARAMETER FilePath
    The path to the JSON file to import. Including the filename.
.EXAMPLE
    PS C:\> import-jsonFile -FilePath "C:\options\myfile.json"
    Calls the import-jsonFile cmdlet in order to import the file and return it to the caller.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="The path to the JSON file to import. Including the filename.")]
        [ValidateNotNullOrEmpty()]
        [String]$FilePath
    )

    #############
    # Execution #
    #############
    try {
        # Import the JSON file
        $jsonFile = get-content -Path $FilePath -Raw | Out-String
    } catch {
        throw "Could not load-in the JSON file. Failed with > $_"
    }

    # Convert the JSON file object to a PSCustomObject
    $pscustomObject = Convertfrom-Json -InputObject $jsonFile

    # Return the JSON file as a PSCustomObject to caller
    $pscustomObject
}