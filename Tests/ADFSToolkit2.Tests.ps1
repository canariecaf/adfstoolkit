

#$EntityID = 'https://test0.release-check.swamid.se/shibboleth'

$EntityID = 'https://test5.release-check.swamid.se/shibboleth'

#region Before reImport
$sp = Get-AdfsRelyingPartyTrust -Identifier $EntityID
$claimRuleSetBefore = New-AdfsClaimRuleSet -ClaimRule $sp.IssuanceTransformRules

$claimRulesHashBeforeImport = @{}
foreach ($cr in $claimRuleSetBefore.ClaimRules) {
    if ($cr -match '^@RuleName = "(.*)"') {
        $claimRulesHashBeforeImport.($Matches[1]) = $cr
    }
}

#$claimRulesHashBeforeImport
# $ruleNames = $rules -split "[\r\n]+" | ? {$_.StartsWith('@RuleName')} | % {$_.replace('@RuleName = ','').trim('"')}
#endregion

Import-ADFSTkMetadata -EntityId $EntityID -ConfigFile C:\ADFSToolkit\config\institution\config.Swamid.xml -ForceUpdate #replace with Test-config

#region After reImport
$sp = Get-AdfsRelyingPartyTrust -Identifier $EntityID
$claimRuleSetAfter = New-AdfsClaimRuleSet -ClaimRule $sp.IssuanceTransformRules

$claimRulesHashAfterImport = @{}
foreach ($cr in $claimRuleSetAfter.ClaimRules) {
    if ($cr -match '^@RuleName = "(.*)"') {
        $claimRulesHashAfterImport.($Matches[1]) = $cr
    }
}

#$claimRulesHashAfterImport
# $ruleNames = $rules -split "[\r\n]+" | ? {$_.StartsWith('@RuleName')} | % {$_.replace('@RuleName = ','').trim('"')}
#endregion

if ($claimRuleSetBefore.ClaimRulesString -eq $claimRuleSetAfter.ClaimRulesString) {
    #All is good
}
else {
    Compare-ADFSTkObject ([string[]]$claimRulesHashBeforeImport.Keys) ([string[]]$claimRulesHashAfterImport.Keys) -CompareType InFirstSetOnly
    Compare-ADFSTkObject ([string[]]$claimRulesHashBeforeImport.Keys) ([string[]]$claimRulesHashAfterImport.Keys) -CompareType InSecondSetOnly
    Compare-ADFSTkObject ([string[]]$claimRulesHashBeforeImport.Values) ([string[]]$claimRulesHashAfterImport.Values) -CompareType AddRemove
    #Value is more important than the Key. Only give a warning/debug info, not error?
}