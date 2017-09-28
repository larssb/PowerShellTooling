####################
# FUNCTION - PREP #
####################
##Requires -Module PSGraph

####################
# FUNCTION - START #
####################
function out-functionHierarchy() {
<#
.DESCRIPTION
    Can be used to generate a graph over the hierarchy of the functions in a PowerShell project. Derived by parsing the functions from the
    module root >> to the outer leaf functions.
.INPUTS
    A PSD1 manifest file to get an entry point that will work as the root of the function hierarchy graph.
.OUTPUTS
    A graphviz graph.
.NOTES
    A function hierarchy graph can be very usefull for getting an overview of a project and can work as deep technical documentation as well.
.EXAMPLE
    out-functionHierarchy -pathToPSD1file .\myModule.psd1;
    This will generate a function hierarchy graphviz graph over the myModule PowerShell module.
.PARAMETER pathToPSD1file
    Full path to the PSD1 manifest file.
.PARAMETER pathToStoreGraph
    The path to store the generated function hierarchy graph.
#>

    # Define parameters
    [CmdletBinding()]param(
        [Parameter(Mandatory=$true, ParameterSetName="default", HelpMessage="Full path to the PSD1 manifest file.")]
        [ValidateNotNullOrEmpty()]
        [string]$pathToPSD1file,
        [Parameter(Mandatory=$false, ParameterSetName="default", HelpMessage="The path to store the generated function hierarchy graph.")]
        [string]$pathToStoreGraph
    )

    #############
    # Execution #
    #############
    <#
        - PREP
    #>
    Import-Module -Name PSGraph;
    . $PSScriptRoot\get-environmentOS.ps1;
    $rootOfTheProject = $pathToPSD1file -replace "\\(?!.*\\).+","";

    <#
        - Gather data on the PowerShell project. For later analyzation and output as a function hierarchy graph via Graphviz.
    #>
    # Import the specified module
    $module = Import-Module -Name $pathToPSD1file -PassThru;

    # Get the root module
    $moduleRoot = $module.RootModule;
    $moduleRootBaseName = $moduleRoot -replace "\..+",""; # Removes .psm1 from the module root name.

    # Get the exported functions (commands), these are the public functions.
    $moduleExportedCommands = $module.ExportedCommands;

    # Iterate over each function to find the function/s it depends on
    foreach ($exportedCommand in $exportedCommands) {
        # Tokenize the function in order to be able to parse the Abstract Syntax Tree
        $ast = [System.Management.Automation.PSParser]::Tokenize( (Get-Content $pathToFunction), [ref]$null);

        # Look for dot-sourcing usage
        $dotSourcedFiles = $ast.where( {$_.content -eq "." -and $_.Type -eq "Operator"} );

        # Go over all lines with dot-sourcing calls
        foreach ($dotSourcedFile in $dotSourcedFiles) {
            #
            $dotSourcedFile.startline

        }

        # Look for import-module usage
        $importedModules = $ast.where( {$_.content -eq "Import-module" -and $_.Type -eq "Command"} )

        # Iterate over all lines with import-module calls
        foreach ($importedModule in $importedModules) {
            # Get the file being imported to go further down the hierarchy rabbit hole.
            $importedFileInfo = $ast.where( {$_.startline -eq $importedModules.startline -and $_.Type -eq "CommandArgument" } );
            $importedFileName = $importedFileInfo.Content -replace ".+\\",""
            $importedFileLocation = Get-ChildItem -Path $rootOfTheProject -Recurse -Filter "$importedFileName*";

            # Get the AST data for the imported file
            $ast = [System.Management.Automation.PSParser]::Tokenize( (Get-Content $importedFileLocation), [ref]$null);


        }
    }

    <#
        - Generate data for the graph
    #>
    $graphData = Graph psFunctionHierarchy {
        # Exported commands
        $exportedCommandNames = $moduleExportedCommands.Values.Name;

        Node projectRoot @{label="$moduleRootBaseName";shape='invhouse'}
        edge projectRoot -To "public functions" @{shape='oval'}
        edge projectRoot -To "private functions" @{shape='oval'}
        Node $exportedCommandNames -NodeScript { "$_()" } @{label={"$_()"};shape='note'}
        edge $exportedCommandNames -FromScript { "public functions" } -ToScript { "$_()" }
    }

    <#
        - Build and export the graph.
    #>
    <#
    if (-Not $PSBoundParameters.ContainsKey('pathToStoreGraph')) {
        $file = [System.IO.Path]::GetRandomFileName();
        $PSBoundParameters["DestinationPath"] = Join-Path $env:temp "$file.$OutputFormat";
    }
    #>

    # Handle issue with path param in Export-PSGraph when on MacOS or Linux.
    $os = get-environmentOS;

    # Output the graph
    if ($os -eq "Windows") {
        $graphvizOutput = $graphData | Export-PSGraph -ShowGraph;
    } else {
        $file = [System.IO.Path]::GetRandomFileName();
        $destinationPath = Join-Path $home "$file.png";
        $graphvizOutput = $graphData | Export-PSGraph -DestinationPath $destinationPath;
        Write-Output "Find the generated graph here: $destinationPath";
    }

    #$graphvizOutput.Fullname
}
##################
# FUNCTION - END #
##################