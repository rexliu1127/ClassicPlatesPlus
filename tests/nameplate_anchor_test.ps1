$createdSource = Get-Content -LiteralPath '.\ClassicPlatesPlus\nameplate_created.lua' -Raw
$addedSource = Get-Content -LiteralPath '.\ClassicPlatesPlus\nameplate_added.lua' -Raw

$requiredCreatedFragments = @(
    'unitFrame:SetAllPoints(nameplate);',
    'unitFrame.parent:SetAllPoints(unitFrame);'
)

foreach ($fragment in $requiredCreatedFragments) {
    if (-not $createdSource.Contains($fragment)) {
        throw "missing custom nameplate frame geometry: $fragment"
    }
}

$requiredAddedFragments = @(
    'unitFrame:SetAllPoints();',
    'unitFrame.parent:SetAllPoints(unitFrame);',
    'unitFrame.name:SetPoint("center", unitFrame, "center", 0, 20);',
    'unitFrame.healthbar:ClearAllPoints();',
    'unitFrame.healthbar:SetPoint("top", unitFrame.name, "bottom", 0, -8);'
)

foreach ($fragment in $requiredAddedFragments) {
    if (-not $addedSource.Contains($fragment)) {
        throw "NAME_PLATE_UNIT_ADDED must restore custom nameplate geometry: $fragment"
    }
}

Write-Output 'PASS: custom nameplates use self-contained unrestricted geometry'
