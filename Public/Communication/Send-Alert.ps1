function Send-Alert() {
<#
.DESCRIPTION
    See notes in the bottom of this file....
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
    Parameter_HelpMessage_text
    Add_a_PARAMETER_per_parameter
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([SPECIFY_THE_RETURN_TYPE_OF_THE_FUNCTION_HERE])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $NAMEOFPARAMETER
    )

    #############
    # Execution #
    #############
    Begin {}
    Process {

    }
    End {}
}

<#
    TODO:

    This is supposed to be a wrapper for different ways to alert of 'x' happening on 'x' system.

    Wraps around:
        - Telegram
        - Slack
            -- Use > https://github.com/RamblingCookieMonster/PSSlack
        - E-mail
            -- Internal PS cmdlet.
#>
