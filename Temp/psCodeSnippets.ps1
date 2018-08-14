<#
    - File & directory related snippets
#>
# Get the directory separator character. Relative to the system.
[System.IO.Path]::DirectorySeparatorChar

# Get the directory part of the value in $path variable. C:\Hejsa\Hej\Hej.txt will return >> C:\Hejsa\Hej\
[System.IO.Path]::GetDirectoryName($path)

<#
    -
#>
# Convert string to number <-- can be used with different number types.
[string]$convertedInt = "1500"
[int]$returnedInt = 0
[bool]$result = [int]::TryParse($convertedInt, [ref]$returnedInt)

# Printing verbose info on a deep object to a log or with write-verbose. E.g.:
write-verbose (Get-EventLog -LogName system -Newest 3 -EntryType Error | Out-String) # The important part is to use the Out-String cmdlet.

# Bit depth test
[Environment]::Is64BitProcess

# Test whether the current PowerShell runs in administrator mode.
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator");