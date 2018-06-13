function Get-RandomizedCleartextPassword() {
<#
.DESCRIPTION
    Generates and returns a password consisting of a random set of [A-z] characters and 1..100 numbers. The return type format, of the password, can be decided via the
    ReturnAs parameter.
.INPUTS
    [String]ReturnAs
.OUTPUTS
    Either:
        - ClearText AKA [String]
    Or:
        - [SecureString]
.NOTES
    - This function IS NOT cryptograpically secure. If that is needed you should certainly look elsewyere.
    - Even though you can ask the function to return a SecureString object, this string is not r e a l l y secure. As it can be reverse marshalled back to its
    cleartext equivalent.

    - On the OutputType specified. Void is declared, however via the ReturnAS parametr you can specify either ClearText or SecureString which in turn means that the
    returntype is of type [String] or [SecureString]. Because PowerShell advanced functions do not really respect/use the [OutputType], it is pure convenience (however nice)
    this is okay.
.EXAMPLE
    PS C:\> Get-RandomizedCleartextPassword -ReturnAs "SecureString"
    Generates and returns a password in the SecureString type format.
.EXAMPLE
    PS C:\> Get-RandomizedCleartextPassword -ReturnAs "ClearText"
    Generates and returns a password in the ClearText type format.
.PARAMETER ReturnAs
    Use this parameter to specify the return type format you want the returned/generated password to have.
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([Void])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="NAME", HelpMessage="MESSAGE", ValueFromPipeline=$false)]
        [ValidateSet('ClearText','SecureString')]
        [String]$ReturnAs
    )

    #############
    # Execution #
    #############
    Begin {}
    Process {
        # Generate the password
        $numbers = 1..100
        $randomNumbers = Get-Random -InputObject $numbers -Count 9
        $chars = [char[]](0..255) -clike '[A-z]'
        $randomChars = Get-Random -InputObject $chars -Count 9
        $charsAndNumbers = $randomNumbers
        $charsAndNumbers += $randomChars
        $charsAndNumbersShuffled = $charsAndNumbers | Sort-Object {Get-Random}

        # Determine the Type format to return the password in.
        if ($ReturnAs -eq "SecureString") {
            $password = ConvertTo-SecureString -String ($charsAndNumbersShuffled -join "") -AsPlainText -Force
        } else {
            $password = ($charsAndNumbersShuffled -join "")
        }
    }
    End {
        # Return the password
        $password
    }
}