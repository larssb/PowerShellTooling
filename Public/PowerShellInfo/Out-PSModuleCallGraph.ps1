#Requires -Module PSGraph
function Out-PSModuleCallGraph() {
<#
.DESCRIPTION
    Out-PSModuleCallGraph generates a call graph on a PowerShell module. The call graph is generated by parsing the public commands/functions of the module being analyzed. Identifying
    the commands/functions each one utilizes. Noting their scope and the chronological order by which they where called. Finally the graph is generated with the PSGraph module and
    saved in the format and on the media specified.
.INPUTS
    [String]ModuleName
    [String]ModuleRoot
.OUTPUTS
    A graphviz graph via the PSGraph module.
.NOTES
    On the analysis:
        - The analysis is based on parsing the AST of each command/public function in the analyzed module. You therefore do not get a sequence like graph over certain calls made
        if 'x' path in the program was followed. Rather the generated call graph represents the code written, static as it is, when parsed line by line, as it is read-in from files
        on disk, to identify the sub-routines called and to be able to present an overview of how parts of the program is thought to interact/can interact with eachother.
    Other:
        - Call graphs can be very useful when working with your own PowerShell module or a PS module developed by external parties. A call graph gives you an overview over the calling
        relationships of commands/functions in a program. Thereby making it possible to get a good overview of a PowerShell module and they its sub-routines interact with eachother.
    Pre-requisites:
        - The PSGraph module should already be installed.
.EXAMPLE
    Out-PSModuleCallGraph -ModuleName Pester
    This will generate a call graph on the Pester module.
.EXAMPLE
    Out-PSModuleCallGraph -ModuleRoot ./PowerShellTooling/
    This will generate a call graph on a properly defined PowerShell module in the folder 'PowerShellTooling'. A sub-folder to current folder. Useful if the module is not installed
    in one of the default PowerShell module installation locations.
.PARAMETER ExcludeDebugCommands
    Used to specify that you wish to exclude common debug commands such as > Write-Verbose & Write-Error.
.PARAMETER ModuleName
    The name of the module to analyze. Assumes that the module is installed in one of the default PowerShell module installation locations.
.PARAMETER ModuleRoot
    Full path to the root folder of the PowerShell module.
.PARAMETER OutputPath
    The path on which to store the generated call graph.
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([Void])]
    param(
        [Parameter()]
        [Parameter(ParameterSetName="ByModuleName")]
        [Parameter(ParameterSetName="ByModuleRoot")]
        [Switch]$ExcludeDebugCommands,
        [Parameter(Mandatory, ParameterSetName="ByModuleName")]
        [ValidateNotNullOrEmpty()]
        [String]$ModuleName,
        [Parameter(Mandatory, ParameterSetName="ByModuleRoot")]
        [ValidateNotNullOrEmpty()]
        [String]$ModuleRoot,
        [Parameter()]
        [Parameter(ParameterSetName="ByModuleName")]
        [Parameter(ParameterSetName="ByModuleRoot")]
        [ValidateNotNullOrEmpty()]
        [String]$OutputPath
    )

    #############
    # Execution #
    #############
    Begin {
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

        # Prepare to exclude common debug commands
        if ($ExcludeDebugCommands) {
            $DebugCommandsToExclude = @('Write-Debug','Write-Error','Write-Verbose')
        } else {
            $DebugCommandsToExclude = @()
        }

        # Short-hand values for commands to be translated to their fullname counterpart
        $FullNameCommands = @{
            "%" = "ForEach-Object"
            "?" = "Where-Object"
        }
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
                # Ordered collection to hold the commands found in the command/function being analyzed
                [System.Collections.ArrayList]$CommandsUsedInfo = New-Object System.Collections.Specialized.OrderedDictionary

                foreach ($Command in $CommandsUsed) {
                    # "Translate" command short-hands to their full-length counterpart.
                    if ($FullNameCommands.Contains($Command.Content)) {
                        [String]$CommandName = $FullNameCommands."$($Command.Content)"
                    } else {
                        [String]$CommandName = $Command.Content
                    }

                    if ($DebugCommandsToExclude.Count -eq 0 -or $DebugCommandsToExclude -notcontains $Command.Content) {
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

                        # COntrol if the command is defined in an external module
                        if (-not $IsPrivateCommand -and -not $IsPublicCommand) {
                            [String]$CommandScope = "External"
                        }

                        # Create a custom object to hold the info on the command analyzed
                        $CommandInfo = @{
                            "CommandName" = $CommandName
                            "CommandScope" = $CommandScope
                        }
                        $CommandInfoCustomObject = New-Object -TypeName PSCustomObject -Property $CommandInfo

                        # Add the command info to the collection
                        $CommandsUsedInfo.Add($CommandInfoCustomObject) | Out-Null
                    } # End of conditional on Exclude
                } # End of foreach on $DebugCommandsToExclude

                # Add the analyzed info to the collection that holds all the aggregated info, derived by analyzing the public function/command currently being iterated over
                $PublicFunctionCommandHierarchy.Add(@{
                    "PublicFunctionAffiliation" = $PublicFunction.Name
                    "Commands" = $CommandsUsedInfo
                }) | Out-Null
            }

            # Add the result of analyzing the Public function to the CallGraphObjects collection
            $CallGraphObjects.Add($PublicFunctionCommandHierarchy) | Out-Null
        }

        <#
            - Generate data for the graph
        #>
        $graphData = Graph ModuleCallGraph {
            # Graph root node. To which all other nodes will be rooted.
            Node ProjectRoot -Attribute @{label="$($Module.Name)";shape='invhouse'}

            # Create nodes on the graph on all the analyzed data
            foreach ($CallGraphObject in $CallGraphObjects) {
                # "Attach" the public command/function to the root node
                Edge ProjectRoot, $CallGraphObject.PublicFunctionAffiliation

                # Control that the command/function actually used any other commands/functions
                if ($CallGraphObject.Commands.CommandsUsedInfo.Count -gt 0) {
                    # Counter used to annotate the nodes with the chronological order by which the command was called
                    $CommandCounter = 1

                    # Create nodes for all the commands/functions the public command/function uses
                    $CallGraphObject.Commands.GetEnumerator() | ForEach-Object {
                        Edge $CallGraphObject.PublicFunctionAffiliation, $_.CommandName -Attributes @{label=$CommandCounter}
                        $CommandCounter++
                    }
                }
            }
        }

        # Output the graph
        $graphData | Export-PSGraph -ShowGraph
    }
}