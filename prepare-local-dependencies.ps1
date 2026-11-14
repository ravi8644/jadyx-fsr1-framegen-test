param(
    [string]$SourceRoot = (Join-Path $env:GITHUB_WORKSPACE 'src\jadyx-0.4.0.1')
)
$ErrorActionPreference = 'Stop'
$workspace = $env:GITHUB_WORKSPACE
$assets = Join-Path $workspace 'assets'
$localDeps = Join-Path $workspace 'local-deps'

$archives = @(
    @{ Name = 'boost-1.92.0-source.zip'; Hash = '2607c6f3093e4a5fe8d2f91aff9253a0059798d97099f5d40c44709d7fa96cf3' },
    @{ Name = 'SDL3-ci-windows-amd64.zip'; Hash = 'f7080a1ec4ed2c6d6a5c7c3fe3a79b5b55157cb7750aa864d7ea609ff94f1855' }
)
foreach ($archive in $archives) {
    $path = Join-Path $assets $archive.Name
    if (-not (Test-Path -LiteralPath $path)) { throw "Espelho local ausente: $($archive.Name)" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $archive.Hash) { throw "SHA-256 inválido para $($archive.Name): $actual" }
}

if (Test-Path -LiteralPath $localDeps) { Remove-Item -LiteralPath $localDeps -Recurse -Force }
$null = New-Item -ItemType Directory -Force -Path $localDeps
$boostRoot = Join-Path $localDeps 'boost'
$sdlRoot = Join-Path $localDeps 'SDL3'
Expand-Archive -LiteralPath (Join-Path $assets 'boost-1.92.0-source.zip') -DestinationPath $boostRoot -Force
Expand-Archive -LiteralPath (Join-Path $assets 'SDL3-ci-windows-amd64.zip') -DestinationPath $sdlRoot -Force
$boostSource = Join-Path $boostRoot 'boost-1.92.0'
if (-not (Test-Path (Join-Path $boostSource 'CMakeLists.txt')) -or
    -not (Test-Path (Join-Path $boostSource 'libs\config\include\boost\version.hpp'))) {
    throw 'A árvore local do Boost não contém CMakeLists.txt e o header boost/version.hpp'
}
if (-not (Test-Path (Join-Path $sdlRoot 'CMakeLists.txt'))) {
    throw 'A árvore local do SDL3 não contém CMakeLists.txt'
}

# O CPM solicita sha512sum remoto antes de considerar *_CUSTOM_DIR em pacotes-artifact.
# Os arquivos locais já foram verificados acima por SHA-256, então a etapa evita essa chamada remota.
$cpmUtil = Join-Path $SourceRoot 'CMakeModules\CPMUtil.cmake'
if (-not (Test-Path -LiteralPath $cpmUtil)) { throw 'CPMUtil.cmake não foi encontrado no source extraído' }
$text = [System.IO.File]::ReadAllText($cpmUtil)
$startMarker = '        # download sha512sum file'
$endMarker = '        file(REMOVE "${sha512sum_file}")'
if (([regex]::Matches($text, [regex]::Escape($startMarker))).Count -ne 1) {
    throw 'Bloco de checksum CPM inesperado; não foi alterado'
}
if (([regex]::Matches($text, [regex]::Escape($endMarker))).Count -ne 1) {
    throw 'Bloco de limpeza CPM inesperado; não foi alterado'
}
$opening = @(
    '        set(custom_dir_var "${ARTIFACT_PACKAGE}_CUSTOM_DIR")',
    '        if (DEFINED ${custom_dir_var} AND NOT "${${custom_dir_var}}" STREQUAL "")',
    '            # Espelho local verificado pelo workflow.',
    '            set(sha512sum_hash "local-package")',
    '        else()',
    $startMarker
) -join "`n"
$closing = $endMarker + "`n        endif()"
$text = $text.Replace($startMarker, $opening).Replace($endMarker, $closing)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($cpmUtil, $text, $utf8NoBom)
if (-not (Select-String -LiteralPath $cpmUtil -Pattern 'Espelho local verificado pelo workflow' -Quiet)) {
    throw 'A proteção CPM para diretórios locais não foi aplicada'
}

Add-Content -LiteralPath $env:GITHUB_ENV -Value "BOOST_CUSTOM_DIR=$boostSource"
Add-Content -LiteralPath $env:GITHUB_ENV -Value "SDL3_CUSTOM_DIR=$sdlRoot"
Write-Host "Boost local: $boostSource"
Write-Host "SDL3 local: $sdlRoot"
Write-Host 'Espelhos validados e diretórios customizados exportados para o CMake.'
