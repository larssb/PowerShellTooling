        <#
            # OLD CODE....use for improving output location.
            # Output the graph
            if ($os -eq "Windows") {
                $graphvizOutput = $graphData | Export-PSGraph -ShowGraph;
            } else {
                $file = [System.IO.Path]::GetRandomFileName();
                $destinationPath = Join-Path $home "$file.png";
                $graphvizOutput = $graphData | Export-PSGraph -DestinationPath $destinationPath;
                Write-Output "Find the generated graph here: $destinationPath";
            }
        #>