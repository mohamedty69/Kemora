$lib_dir = "S:\Kemora\kemora_app\lib"
$dart_files = Get-ChildItem -Path $lib_dir -Recurse -Filter *.dart

foreach ($file in $dart_files) {
    $content = Get-Content $file.FullName -Raw
    $matches = [regex]::Matches($content, "import\s+['""]([^'""]+)['""](.*)")
    foreach ($match in $matches) {
        $imp = $match.Groups[1].Value
        if ($imp.StartsWith("package:kemora_app/")) {
            $rel = $imp.Replace("package:kemora_app/", "")
            # Need to handle forward slashes in path
            $rel = $rel.Replace("/", "\")
            $target = Join-Path $lib_dir $rel
            if (-not (Test-Path $target)) {
                Write-Host "$($file.FullName): Invalid package import: $imp"
            }
        } elseif (-not $imp.StartsWith("package:") -and -not $imp.StartsWith("dart:")) {
            $dir = Split-Path $file.FullName
            $imp_win = $imp.Replace("/", "\")
            $target = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($dir, $imp_win))
            if (-not (Test-Path $target)) {
                Write-Host "$($file.FullName): Invalid relative import: $imp"
            }
        }
    }
}
