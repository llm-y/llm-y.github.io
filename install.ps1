# Pasang llmy dari GitHub Release: https://ll.my.id
#   irm https://ll.my.id/install.ps1 | iex
# $env:LLMY_VERSION = 'v0.1.0'  versi tertentu (bawaan: terbaru)
& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    $repo = 'https://github.com/llm-y/agent/releases'
    # Windows ARM menjalankan binary x64 lewat emulasi.
    $file = 'llmy-x86_64-pc-windows-msvc.zip'
    if ($env:LLMY_VERSION) {
        $url = "$repo/download/v$($env:LLMY_VERSION.TrimStart('v'))"
    } else {
        $url = "$repo/latest/download"
    }
    $dir = Join-Path $env:LOCALAPPDATA 'Programs\llmy'
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory $tmp | Out-Null
    try {
        Write-Host "Mengunduh $file"
        Invoke-WebRequest -UseBasicParsing "$url/$file" -OutFile "$tmp\$file"
        Invoke-WebRequest -UseBasicParsing "$url/SHA256SUMS" -OutFile "$tmp\SHA256SUMS"
        $line = Get-Content "$tmp\SHA256SUMS" | Where-Object { $_.EndsWith(" $file") }
        if (-not $line) { throw "checksum untuk $file tidak ada" }
        $want = ($line -split '\s+')[0]
        $got = (Get-FileHash "$tmp\$file" -Algorithm SHA256).Hash
        if ($got -ne $want) { throw 'checksum tidak cocok; instalasi dibatalkan' }
        Expand-Archive "$tmp\$file" "$tmp\isi"
        New-Item -ItemType Directory -Force $dir | Out-Null
        Copy-Item -Force "$tmp\isi\llmy.exe" "$dir\llmy.exe"
    } finally {
        Remove-Item -Recurse -Force $tmp
    }
    $path = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($path -split ';') -notcontains $dir) {
        [Environment]::SetEnvironmentVariable('Path', "$path;$dir".TrimStart(';'), 'User')
        Write-Host 'PATH diperbarui; buka terminal baru.'
    }
    $env:Path += ";$dir"
    Write-Host "Terpasang: $(& "$dir\llmy.exe" --version) di $dir"
    if (-not (Get-Command bash -ErrorAction SilentlyContinue) -and -not (Test-Path "$env:ProgramFiles\Git\bin\bash.exe")) {
        Write-Host 'Tool bash butuh Git for Windows: https://git-scm.com/download/win'
    }
    if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
        Write-Host 'Ollama belum ada. Pasang dari https://ollama.com/download, lalu: ollama pull qwen3.5:9b'
    }
}
