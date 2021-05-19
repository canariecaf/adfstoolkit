#region Setup
$Global:ADFSTkSkipMetadataSignatureCheck = $true

if ([string]::IsNullOrEmpty($Global:ADFSTkPaths))
{
    $Global:ADFSTkPaths = Get-ADFSTkPaths
}

$TestPath = Join-Path (Split-Path $Global:ADFSTkPaths.modulePath -Parent) Tests

if (!(Test-Path function:Compare-ADFSTkObject)) {
    . (Join-Path $Global:ADFSTkPaths.modulePath "Private\Compare-ADFSTkObject.ps1")
}

$SucceededTests = @()
$FailedTests = @()
#endregion

#region Open BaseLine
Write-Host "Loading the BaseLine... " -NoNewline
$FileName = "ClaimsBaseline.xml"
$ImportPath = Join-Path $TestPath $FileName

if (Test-Path $ImportPath) {
    $BaseLine = Import-Clixml $ImportPath
    Write-Host "Done!" -ForegroundColor Green
}
else {
    Throw "The file '$ImportPath' does not exist!"
}
#endregion

#region Import Test SP's
Write-Host "Importing the Test SP's... " -NoNewline
$TestPath = Join-Path (Split-Path $Global:ADFSTkPaths.modulePath -Parent) Tests
$ConfigFilePath = Join-Path $TestPath config.ADFSTkTest.xml
$MetadataFilePath = Join-Path $TestPath Test-metadata.xml

for ($i = 0; $i -le 5; $i++) {
    $EntityID = "urn:adfstk:sp:test$i"
    Import-ADFSTkMetadata -EntityId $EntityID -ConfigFile $ConfigFilePath -LocalMetadataFile $MetadataFilePath -criticalHealthChecksOnly -ForceUpdate -Silent
}
Write-Host "Done!" -ForegroundColor Green
#endregion

#region Get Claims from Test SP's
Write-Host "Loading all claim rules... " -NoNewline
$claimRulesHashAfterImport = @{}
for ($i = 0; $i -le 5; $i++) {
    $claimRuleHashAfterImport = @{}
    $EntityID = "urn:adfstk:sp:test$i"
    $sp = Get-AdfsRelyingPartyTrust -Identifier $EntityID
    $claimRuleSetAfter = New-AdfsClaimRuleSet -ClaimRule $sp.IssuanceTransformRules

    foreach ($cr in $claimRuleSetAfter.ClaimRules) {
        if ($cr -match '^@RuleName = "(.*)"') {
            $claimRuleHashAfterImport.($Matches[1]) = $cr
        }
    }
    $claimRulesHashAfterImport.$EntityID = [PSCustomObject]@{
        ClaimRuleSet  = $claimRuleSetAfter
        ClaimRuleHash = $claimRuleHashAfterImport
    }
}
Write-Host "Done!" -ForegroundColor Green
#endregion

#region Test each SP
for ($i = 0; $i -le 5; $i++) {
    $EntityID = "urn:adfstk:sp:test$i"
    Write-Host "Testing $EntityID..."
    $BaseLineRulesHash = $BaseLine.$EntityID

    if ($BaseLineRulesHash.ClaimRuleSet.ClaimRulesString -eq $claimRulesHashAfterImport.$EntityID.ClaimRuleSet.ClaimRulesString) {
        #All is good
        Write-Host "All claims matches the BaseLine!" -ForegroundColor Green
        $SucceededTests += $EntityID
    }
    else {
        Write-Host "Not all claims matches the BaseLine!" -ForegroundColor Yellow
        $FailedTests += $EntityID
        $compare = Compare-ADFSTkObject ([string[]]$BaseLineRulesHash.ClaimRuleHash.Values) ([string[]]$claimRulesHashAfterImport.$EntityID.ClaimRuleHash.Values) -CompareType AddRemove

        if ($compare.MembersInRemoveSet -gt 0) {
            Write-Host "The following rules could not be found in current claim rules:" -ForegroundColor Yellow
            $compare.RemoveSet
        }
        Write-Host " "
        Write-Host "--------------------------" -ForegroundColor Yellow
        Write-Host " "
        if ($compare.MembersInAddSet -gt 0) {
            Write-Host "The following rules could not be found in BaseLine:" -ForegroundColor Yellow
            $compare.AddSet
        }
    }
}
#endregion

#region Summary
if ($FailedTests.Count -gt 0)
{
    Write-Host "Not all tests were successfully!" -ForegroundColor Yellow
    Write-Host ("{0}/{1} failed!" -f $FailedTests.Count, ($SucceededTests.Count + $FailedTests.Count)) -ForegroundColor Yellow
}
else {
    Write-Host "All $($SucceededTests.Count) succeeded!" -ForegroundColor Green
}

#endregion