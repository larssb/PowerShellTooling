function Request-Folder() {
<#
.DESCRIPTION
    Long description
.INPUTS
    Inputs (if any)
.OUTPUTS
    Outputs (if any)
.NOTES
    General notes
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.PARAMETER NAME_OF_THE_PARAMETER_WITHOUT_THE_QUOTES
    Parameter HelpMessage text
    Add a .PARAMETER per parameter
#>

    # Parameter definitions
    [CmdletBinding()]
    [OutputType([Void])]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="WinPlatform", HelpMessage="The name that the 'folder asking' windows should have.")]
        [ValidateNotNullOrEmpty()]
        [String]$WindowDescription
    )

    #############
    # EXECUTION #
    #############
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | out-null;
    $foldername = New-Object System.Windows.Forms.folderbrowserdialog;
    $foldername.Description = $WindowDescription;
    $foldername.showdialog()

    # Define ResolveFolder variable
    $SpecifiedFolder = $foldername.SelectedPath;

    # Have to state -ne '' because $foldername is not $null. It must be an empty string and that is not the same is $null
    if($SpecifiedFolder -ne '') {
        New-Variable -Name SpecifiedFolder -Value ($SpecifiedFolder) -Scope 1
    }
}