$source = Get-Content -LiteralPath '.\ClassicPlatesPlus\auras.lua' -Raw

if ($source.Contains('first_y *- CFG.AurasScale')) {
    throw 'normal aura first-layer height must not use a negative scale'
}

if (-not $source.Contains('first_y * CFG.AurasScale')) {
    throw 'normal aura first-layer height must use the configured positive scale'
}

Write-Output 'PASS: aura icon mask layout uses a positive frame height'
