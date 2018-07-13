#Requires -Module PSGraph
function Out-FunctionHierarchy() {
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
.PARAMETER ModuleName
    The name of the module to analyze. Assumes that the module is installed in one of the default PowerShell module installation paths.
.PARAMETER ModuleRoot
    Full path to the root folder of the PowerShell module.
.PARAMETER PathToStoreGraph
    The path to store the generated function hierarchy graph.
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([Void])]
    param(
        [Parameter(Mandatory, ParameterSetName="ByModuleName")]
        [ValidateNotNullOrEmpty()]
        [String]$ModuleName,
        [Parameter(Mandatory, ParameterSetName="ByModuleRoot")]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleRoot,
        [Parameter()]
        [string]$pathToStoreGraph
    )

    #############
    # Execution #
    #############
    Begin {
        #Import-Module -Name PSGraph
        . $PSScriptRoot\..\SystemInfo\get-environmentOS.ps1
        #$rootOfTheProject = $pathToPSD1file -replace "\\(?!.*\\).+",""

        if ($PSBoundParameters.ContainsKey('ModuleName')) {
            # Import the specified module by name. Therefore, loaded from one of the default PowerShell module path locations.
            $Module = Import-Module -DisableNameChecking -Name $ModuleName -PassThru
        } else {
            # Import the specified module by its fullname/path.
            $Module = Import-Module -DisableNameChecking -Name $ModuleRoot -PassThru

        }

        # Collection to hold private functions
        [System.Collections.ArrayList]$PrivateFunctions = New-Object System.Collections.ArrayList

        # Collection to hold the call hierarchy of the analyzed module
        [System.Collections.ArrayList]$CallGraphObjects = New-Object System.Collections.ArrayList
    }
    Process {
        <#
            - Get the private functions in the module. So that we can distinguise these from the external cmdlets/functions used by the module
        #>
        # Get all PS1 files
        $PS1Files = (Get-ChildItem -Path $Module.ModuleBase -Filter '*.ps1' -Recurse)
        Write-Verbose -Message "All *.ps1 files retrieved > $($PS1Files | Out-String)"

        # Run through all the retrieved *.PS1 files >> to identify declared functions in them
        foreach ($PS1File in $PS1Files) {
            $ast = [System.Management.Automation.PSParser]::Tokenize( (Get-Content -Path $PS1File.FullName), [ref]$null)

            # Identify the declared functions in the file
            $DeclaredFunctions = $ast.where( { $_.Type -eq "Keyword" -and $_.Content -eq "function" } )
            Write-Verbose -Message "There is $($DeclaredFunctions.Count) declared functions in the file named $($PS1File.Name)."

            foreach ($DeclaredFunction in $DeclaredFunctions) {
                # Derive the name of the declared function
                [String]$FunctionName = ($ast.where( { $_.Startline -eq $DeclaredFunction.StartLine -and $_.Type -eq "CommandArgument" } )).Content

                # Control if the function is a public function in the module being analyzed
                if (-not $PublicFunctions.Name.Contains($FunctionName)) {
                    $PrivateFunctions.Add($FunctionName) | Out-Null
                    Write-Verbose -Message "Found a private function named $FunctionName"

                    # Parse the AST of the private function to find the CommandArguments used

                } else {
                    Write-Verbose -Message "The function named $FunctionName is a public function"
                }
            }
        }

        <#
            Public functions.
        #>
        # Get the public functions loaded by the module
        $PublicFunctions = Get-Command -Module $Module.Name
        Write-Verbose -Message "The public functions retrieved > $($PublicFunctions | Out-String)"

        # Parse the AST of the public funtions to discover the CommandArguments used
        foreach ($PublicFunction in $PublicFunctions) {
            # Collection to hold the commands used by the function. Ordered to reflect the point-in-time of each commad invocation.
            [System.Collections.ArrayList]$PublicFunctionCommandHierarchy = New-Object System.Collections.ArrayList

            # Tokenize the AST
            $ast = [System.Management.Automation.PSParser]::Tokenize( $($PublicFunction.Definition), [ref]$null)

            # Get the commands used in the code (references to other functions/cmdlets in the code)
            $CommandsUsed = $ast.where( { $_.Type -eq "Command" } )

            if ($null -ne $CommandsUsed) {
                [System.Collections.ArrayList]$CommandsUsedInfo = New-Object System.Collections.Specialized.OrderedDictionary
                foreach ($Command in $CommandsUsed) {
                    # Control if it is a private function in the module
                    $IsPrivateCommand = $PrivateFunctions.Contains($Command)
                    if ($IsPrivateCommand) {
                        [String]$CommandScope = "Private"
                    }

                    # Control if it is a public function in the module
                    $IsPublicCommand = $PublicFunctions.Contains($Command)
                    if ($IsPublicCommand) {
                        [String]$CommandScope = "Public"
                    }

                    # Is the command defined in an external module
                    if (-not $IsPrivateCommand -and -not $IsPublicCommand) {
                        [String]$CommandScope = "External"
                    }

                    # Create a custom object to hold the info on the command analyzed
                    $CommandInfo = @{
                        "CommandName" = $Command
                        "CommandScope" = $CommandScope
                    }
                    $CommandInfoCustomObject = New-Object -TypeName PSCustomObject -Property $CommandInfo

                    # Add the command info to the collection
                    $CommandsUsedInfo.Add($CommandInfoCustomObject)
                }

                # Add the analyzed info to the collection that holds all the aggregated info, derived by analyzing the public function/command currently being iterated over
                $PublicFunctionCommandHierarchy.Add(@{
                    "PublicFunctionAffiliation" = $PublicFunction.Name
                    "Commands" = $CommandsUsedInfo
                }) | Out-Null
            }

            # Add the result of analyzing the Public function to the CallGraphObjects collection
            $CallGraphObjects.Add($PublicFunctionCommandHierarchy) | Out-Null
        }

        # Iterate over each function to find the function/s it depends on
<#         foreach ($exportedCommand in $exportedCommands) {
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
        } #>

        <#
            - Generate data for the graph
        #>
        $graphData = Graph ModuleCallGraph {
            Node -Name ProjectRoot @{label="$($Module.Name)";shape='invhouse'}
            #edge ProjectRoot -To "Public Functions" @{shape='oval'}
            #edge projectRoot -To "private functions" @{shape='oval'}
            #Node -Name $exportedCommandNames -NodeScript { $_.Name } @{label = { $_.Name }; shape = 'note'}


            foreach ($CallGraphObject in $CallGraphObjects) {

                foreach ($Command in $CommandInfo) {

                }
                Edge $CallGraphObject -FromScript { $Module.Name } -ToScript { $_.Name }
            }
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
}