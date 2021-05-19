#Add param to save Institution BaseLine.xml


$Global:ADFSTkSkipMetadataSignatureCheck = $true

#region Import Test SP's
if ([string]::IsNullOrEmpty($Global:ADFSTkPaths))
{
    $Global:ADFSTkPaths = Get-ADFSTkPaths
}

if (!(Test-Path function:Get-ADFSTkAnswer))
{
    . (Join-Path $Global:ADFSTkPaths.modulePath "Private\Get-ADFSTkAnswer.ps1")
}

$TestPath = Join-Path (Split-Path $Global:ADFSTkPaths.modulePath -Parent) Tests
$ConfigFilePath = Join-Path $TestPath config.ADFSTkTest.xml
$MetadataFilePath = Join-Path $TestPath Test-metadata.xml

for ($i = 0; $i -le 5; $i++) {
    $EntityID = "urn:adfstk:sp:test$i"
    Import-ADFSTkMetadata -EntityId $EntityID -ConfigFile $ConfigFilePath -LocalMetadataFile $MetadataFilePath -criticalHealthChecksOnly -ForceUpdate
}
#endregion

#region Get Claims from Test SP's
$claimRulesHash = @{}
for ($i = 0; $i -le 5; $i++) {
    $claimRuleHash = @{}
    $EntityID = "urn:adfstk:sp:test$i"
    $sp = Get-AdfsRelyingPartyTrust -Identifier $EntityID
    $claimRuleSet = New-AdfsClaimRuleSet -ClaimRule $sp.IssuanceTransformRules

    foreach ($cr in $claimRuleSet.ClaimRules) {
        if ($cr -match '^@RuleName = "(.*)"') {
            $claimRuleHash.($Matches[1]) = $cr
        }
    }

    $claimRulesHash.$EntityID = [PSCustomObject]@{
        ClaimRuleSet  = $claimRuleSet
        ClaimRuleHash = $claimRuleHash
    }
}

#endregion

#region Export Claim Rules 

$FileName = "ClaimsBaseline.xml"
$ExportPath = Join-Path $TestPath $FileName
if ((Test-Path $ExportPath) -and -not (Get-ADFSTkAnswer "$FileName already exists. Do you want to overwrite it?" -DefaultYes)) {
    #Don't overwrite the existing file
    Write-Host "Export aborted!" -ForegroundColor Yellow
}
else {
    $claimRulesHash | Export-Clixml -Path $ExportPath 
    Write-Host "Export done!" -ForegroundColor Green
}

#endregion
