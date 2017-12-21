# Get the directory separator character. Relative to the system.
[System.IO.Path]::DirectorySeparatorChar

# Convert string to number <-- can be used with different number types.
[string]$convertedInt = "1500"
[int]$returnedInt = 0
[bool]$result = [int]::TryParse($convertedInt, [ref]$returnedInt)

# Printing verbose info on a deep object to a log or with write-verbose. E.g.:
write-verbose (Get-EventLog -LogName system -Newest 3 -EntryType Error | Out-String) # The important part is to use the Out-String cmdlet.

# Bit depth test
[Environment]::Is64BitProcess