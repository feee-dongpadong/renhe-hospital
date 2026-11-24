$out = & java -XshowSettings:properties -version 2>&1 | Out-String
if ($out -match 'java\.home = (.+)') {
    $home = $Matches[1].Trim()
    if (Test-Path (Join-Path $home 'bin\javac.exe')) {
        Write-Output $home
        exit 0
    }
}

$cmd = Get-Command javac -ErrorAction SilentlyContinue
if ($cmd) {
    $item = Get-Item $cmd.Source -ErrorAction SilentlyContinue
    if ($item -and $item.Target) {
        $t = $item.Target
        if ($t -is [array]) { $p = $t[0] } else { $p = $t }
        if (-not [System.IO.Path]::IsPathRooted($p)) {
            $p = Join-Path $item.DirectoryName $p
        }
        $resolved = Resolve-Path $p -ErrorAction SilentlyContinue
        if ($resolved) {
            $home = Split-Path (Split-Path $resolved.Path)
            if (Test-Path (Join-Path $home 'bin\javac.exe')) {
                Write-Output $home
                exit 0
            }
        }
    }
}

$roots = @(
    (Join-Path $env:ProgramFiles 'Java'),
    (Join-Path $env:ProgramFiles 'Eclipse Adoptium'),
    (Join-Path $env:ProgramFiles 'Microsoft'),
    (Join-Path $env:ProgramFiles 'BellSoft')
)
foreach ($root in $roots) {
    if (Test-Path $root) {
        $hit = Get-ChildItem $root -Directory -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path $_.FullName 'bin\javac.exe') } |
            Sort-Object Name -Descending |
            Select-Object -First 1
        if ($hit) {
            Write-Output $hit.FullName
            exit 0
        }
    }
}

exit 1
