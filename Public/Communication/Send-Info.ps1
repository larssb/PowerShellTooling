function Send-Info() {
<#
.DESCRIPTION
    See notes in the bottom of this file....
.INPUTS
    [String] FormOfCommunication
    [Hashtable] SplattingHashtable
.OUTPUTS
    [Bool] representing the result of communicating info via the selected form of communication.
.NOTES
    Error handling in relation to Send-Info(). Send-Info throws so the caller should catch and log the error and act accordingly
    from there.
.EXAMPLE
    PS C:\> $Result = Send-Info -FormOfCommunication 'E-mail' -SplattingHashtable $EmailOptions
    Explanation of what the example does
.EXAMPLE
    PS C:\> $Result = Send-Info -FormOfCommunication 'E-mail' -
    Explanation of what the example does
.PARAMETER Config
    An object specifying the options to use on the form of communiation chosen. The type of the variable should be a [String] in
    the JSON format.
.PARAMETER FormOfCommunication
    The form of communication channel to use when sending out info on an event.

    Supported forms of communication.
    - E-mail:
    - Slack:
    - SMS:
    - Telegram:
.PARAMETER GlobalConfig
    Tells Send-Info that it can expect a variable > $Global:Config so named and defined. The type of the variable should be a
    [String] in the JSON format. Send-Info will then read this variable and use the options it specifies on the form of
    communication chosen.
.PARAMETER SplattingHashtable
    A HashTable collection. Containing the parameters/arguments and their corresponding values to be used when communcating via
    one of the selected forms of communication (selected via the FormOfCommunication parameter).
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([Bool])]
    param(
        [Parameter(Mandatory, ParameterSetName="OptionsViaConfigString")]
        [ValidateNotNullOrEmpty()]
        [Alias('CommunicationOptions')]
        [String]$Config,
        [Parameter(Mandatory, ParameterSetName="OptionsViaConfig")]
        [Parameter(Mandatory, ParameterSetName="OptionsViaGlobalConfig")]
        [Parameter(Mandatory, ParameterSetName="OptionsViaSplatting")]
        [ValidateSet('E-mail','Slack','Telegram')]
        [String]$FormOfCommunication,
        [Parameter(Mandatory, ParameterSetName="OptionsViaGlobalConfig")]
        [ValidateNotNullOrEmpty()]
        [Alias('CommunicationOptions')]
        [Switch]$GlobalConfig,
        [Parameter(Mandatory, ParameterSetName="OptionsViaSplatting")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$SplattingHashtable
    )

    #############
    # Execution #
    #############
    Begin {
        # Convert to custom PS object which makes the Config data easier to work with.
        if ($PSBoundParameters.ContainsKey('Config') -or $PSBoundParameters.ContainsKey('GlobalConfig')) {
            [PSCustomObject]$ConfigConverted = $CommunicationOptions | ConvertFrom-Json
        }
    }
    Process {
        switch ($FormOfCommunication) {
            'E-mail' {
                try {
                    Send-MailMessage @SplattingHashtable -ErrorAction Stop
                } catch {
                    throw "Sending the e-mail to $($SplattingHashtable.To). Failed with > $_"
                }
            }
            'Slack' {
                try {
                    Send-SlackMessage @SplattingHashtable
                } catch {
                    throw " . Failed with > $_"
                }
            }
            'Telegram' {

            }
            Default {}
        }
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
