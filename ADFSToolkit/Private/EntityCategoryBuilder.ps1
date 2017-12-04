#========================================================================== 
# NAME: Import-SWAMIDEntityCategoryBuilder.ps1
#
# DESCRIPTION: Makes TransformRules from EntityCategories and/or manual 
#              Entities
#
# 
# AUTHOR: Johan Peterson (Linköping University)
# DATE  : 2014-03-18
#
# PUBLISH LOCATION: C:\Published Powershell Scripts\ADFS
#
#=========================================================================
#  Version     Date      	Author              	Note 
#  ----------------------------------------------------------------- 
#   1.0        2014-03-18	Johan Peterson (Linköping University)	Initial Release
#   1.1        2014-03-18	Johan Peterson (adm)	First Publish
#   1.2        2014-03-19	Johan Peterson (adm)	New TransformsRule Group called Base with only transient-id in
#   1.3        2014-05-23	Johan Peterson (adm)	Added eduPersonScopedAffiliation to hr..se
#   1.4        2015-03-05	Johan Peterson (adm)	Added entity category http://refeds.org/category/research-and-scholarship
#   1.5        2015-04-24	Johan Peterson (adm)	Fixed Get-IssuanceTransformRules so you can use only a EntityId without EntityCategories, also changed Transient-Id to not hardcode sp.swamid.se
#   1.6        2015-04-24	Johan Peterson (adm)	Fixed Get-IssuanceTransformRules so it can handle entity-id not having sp.swamid.se hardcoded
#   1.7        2015-05-13	Johan Peterson (adm)	Added AeTM as ManualSP
#   1.8        2015-05-22	Johan Peterson (adm)	Fixed AeTM
#   1.9        2017-10-19	Johan Peterson (adm)	Fixed a bug where a RP with no Entity Category would not receive any Issuance Transform Rules
#=========================================================================

function Get-IssuanceTransformRules
{
param (

    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
    [string[]]$EntityCategories,
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
    [string]$EntityId,
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
    $RequestedAttribute
)


$AllAttributes = Import-AllAttributes
$AllTransformRules = Import-AllTransformRules

$IssuanceTransformRuleCategories = Import-IssuanceTransformRuleCategories -RequestedAttribute $RequestedAttribute
$IssuanceTransformRulesManualSP = get-ADFSTkManualSPSettings


### Transform Entity Categories

$TransformedEntityCategories = @()

$AttributesFromStore = @{}
$IssuanceTransformRules = [Ordered]@{}

if ($EntityCategories -eq $null)
{
    $TransformedEntityCategories += "NoEntityCategory"
}
else
{
    if ($EntityCategories.Contains("http://refeds.org/category/research-and-scholarship")) 
    {
        $TransformedEntityCategories += "research-and-scholarship" 
    }

    if ($EntityCategories.Contains("http://www.geant.net/uri/dataprotection-code-of-conduct/v1")) 
    {
        $TransformedEntityCategories += "ReleaseToCoCo" 
    }

    if ($EntityCategories.Contains("http://www.swamid.se/category/research-and-education") -and `
        ($EntityCategories.Contains("http://www.swamid.se/category/eu-adequate-protection") -or `
        $EntityCategories.Contains("http://www.swamid.se/category/nren-service") -or `
        $EntityCategories.Contains("http://www.swamid.se/category/hei-service")))
    {
        $TransformedEntityCategories += "entity-category-research-and-education" 
    }

    if ($EntityCategories.Contains("http://www.swamid.se/category/sfs-1993-1153"))
    {
        $TransformedEntityCategories += "entity-category-sfs-1993-1153" 
    }

    #if ($EntityID.Identifier.Contains("*..se") THEN ADD Entitetskategori

    #if ($EntityCategories.Contains("http://www.swamid.se/category/hei-service"))
    #{
    #    $TransformedEntityCategories += "all-requested-attributes" 
    #}
    #
    #if ($EntityCategories.Contains("http://www.swamid.se/category/nren-service"))
    #{
    #    $TransformedEntityCategories += "all-requested-attributes" 
    #}
    #
    #if ($EntityCategories.Contains("http://www.swamid.se/category/eu-adequate-protection"))
    #{
    #    $TransformedEntityCategories += "all-requested-attributes" 
    #}

    if ($TransformedEntityCategories.Count -eq 0)
    {
        $TransformedEntityCategories += "NoEntityCategory"
    }

###

}

#region Add TransformRules from categories
$TransformedEntityCategories | % { 

    if ($_ -ne $null -and $IssuanceTransformRuleCategories.ContainsKey($_))
    {
        foreach ($Rule in $IssuanceTransformRuleCategories[$_].Keys) { 
            if ($IssuanceTransformRuleCategories[$_][$Rule] -ne $null)
            {
                $IssuanceTransformRules[$Rule] = $IssuanceTransformRuleCategories[$_][$Rule].Rule.Replace("[ReplaceWithSPNameQualifier]",$EntityId)
                foreach ($Attribute in $IssuanceTransformRuleCategories[$_][$Rule].Attribute) { $AttributesFromStore[$Attribute] = $AllAttributes[$Attribute] }
            }
        }
    }
}
#endregion



if ($EntityId -ne $null -and $IssuanceTransformRulesManualSP.ContainsKey($EntityId))
{
    foreach ($Rule in $IssuanceTransformRulesManualSP[$EntityId].Keys) { 
        if ($IssuanceTransformRulesManualSP[$EntityId][$Rule] -ne $null)
        {                
            $IssuanceTransformRules[$Rule] = $IssuanceTransformRulesManualSP[$EntityId][$Rule].Rule.Replace("[ReplaceWithSPNameQualifier]",$EntityId)
            foreach ($Attribute in $IssuanceTransformRulesManualSP[$EntityId][$Rule].Attribute) { 
                $AttributesFromStore[$Attribute] = $AllAttributes[$Attribute] 
            }
        }
    }
}

#region Create Stores
if ($AttributesFromStore.Count)
{
    $FirstRule = ""
    foreach ($store in ($Settings.configuration.storeConfig.stores.store | sort order))
    {
        #region Active Directory Store
        if ($store.name -eq "Active Directory")
        {
            $currentStoreAttributes = $AttributesFromStore.Values | ? store -eq $store.name
            if ($currentStoreAttributes.Count -gt 0)
            {
                $FirstRule += @"

                @RuleName = "Retrieve Attributes from AD"
                c:[Type == "$($store.type)", Issuer == "$($store.issuer)"]
                => add(store = "$($store.name)", 
                types = ("$($currentStoreAttributes.type -join '","')"), 
                query = ";$($currentStoreAttributes.name -join ',');{0}", param = c.Value);

"@
            }
        }
        #endregion

        #region SQL Store

        #endregion

        #region LDAP Store

        #endregion

        #region Custom Store
        if ($store.name -eq "Custom Store")
        {
            $currentStoreAttributes = $AttributesFromStore.Values | ? store -eq $store.name
            if ($currentStoreAttributes -ne $null)
            {
                $FirstRule += @"

                @RuleName = "Retrieve Attributes from Custom Store"
                c:[Type == "$($store.type)", Issuer == "$($store.issuer)"]
                => add(store = "$($store.name)", 
                types = ("$($currentStoreAttributes.type -join '","')"), 
                query = ";$($currentStoreAttributes.name -join ',');{0}", param = "[ReplaceWithSPNameQualifier]", param = c.Value);

"@
            }
        }
        #endregion
    }

    return $FirstRule.Replace("[ReplaceWithSPNameQualifier]",$EntityId) + $IssuanceTransformRules.Values
}
else
{
    return $IssuanceTransformRules.Values
}
#endregion
}

function Import-IssuanceTransformRuleCategories {
param (
    $RequestedAttribute
)
    ### Create AttributeStore variables
    $IssuanceTransformRuleCategories = @{}

    $RequestedAttributes = @{}

    if (![string]::IsNullOrEmpty($RequestedAttribute))
    {
        $RequestedAttribute | % {
            $RequestedAttributes.($_.Name) = $_.friendlyName
        }
    }

    ### Released to SP:s without Entity Category

    $TransformRules = [Ordered]@{}

    $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    $TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID

    $IssuanceTransformRuleCategories.Add("NoEntityCategory",$TransformRules)
    
    ### research-and-scholarship ###

    $TransformRules = [Ordered]@{}

    $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    $TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID
    $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
    #eduPersonUniqueID
    $TransformRules.mail = $AllTransformRules.mail
    $TransformRules.displayName = $AllTransformRules.displayName
    $TransformRules.givenName = $AllTransformRules.givenName
    $TransformRules.sn = $AllTransformRules.sn
    $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation

    $IssuanceTransformRuleCategories.Add("research-and-scholarship",$TransformRules)

    ### GEANT Dataprotection Code of Conduct
    
    $TransformRules = [Ordered]@{}

    if ($RequestedAttributes.Count -gt 0)
    {
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.10")) { 
            $TransformRules.eduPersonTargetedID = $AllTransformRules.'transient-id'
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.10")) { 
            $TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.6")) { 
            $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:0.9.2342.19200300.100.1.3")) { 
            $TransformRules.mail = $AllTransformRules.mail
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.16.840.1.113730.3.1.241")) { 
            $TransformRules.displayName = $AllTransformRules.displayName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.3")) { 
            $TransformRules.cn = $AllTransformRules.cn
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.42")) { 
            $TransformRules.displayName = $AllTransformRules.givenName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.4")) { 
            $TransformRules.cn = $AllTransformRules.sn
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.9")) {
            $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.1")) {
            $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonAffiliation
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.10")) { 
            $TransformRules.displayName = $AllTransformRules.organizationName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.2428.90.1.6")) { 
            $TransformRules.displayName = $AllTransformRules.norEduOrgAcronym 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.6")) { 
            $TransformRules.displayName = $AllTransformRules.countryName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:0.9.2342.19200300.100.1.43")) { 
            $TransformRules.displayName = $AllTransformRules.friendlyCountryName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.25178.1.2.9")) { 
            $TransformRules.schacHomeOrganization = $AllTransformRules.schacHomeOrganization
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.25178.1.2.10")) {
            $TransformRules.schacHomeOrganizationType = $AllTransformRules.schacHomeOrganizationType
        }
    }

    $IssuanceTransformRuleCategories.Add("ReleaseToCoCo",$TransformRules)
    
    ### SWAMID Entity Category Research and Education

    $TransformRules = [Ordered]@{}

    $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    $TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID
    $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
    #eduPersonUniqueID
    $TransformRules.mail = $AllTransformRules.mail
    $TransformRules.displayName = $AllTransformRules.displayName
    $TransformRules.cn = $AllTransformRules.cn
    $TransformRules.givenName = $AllTransformRules.givenName
    $TransformRules.sn = $AllTransformRules.sn
    $TransformRules.eduPersonAssurance = $AllTransformRules.eduPersonAssurance
    $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
    $TransformRules.o = $AllTransformRules.o
    $TransformRules.norEduOrgAcronym = $AllTransformRules.norEduOrgAcronym
    $TransformRules.c = $AllTransformRules.c
    $TransformRules.co = $AllTransformRules.co
    $TransformRules.schacHomeOrganization = $AllTransformRules.schacHomeOrganization

    $IssuanceTransformRuleCategories.Add("entity-category-research-and-education",$TransformRules)

    ### SWAMID Entity Category SFS 1993:1153

    $TransformRules = [Ordered]@{}

    $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    $TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID
    $TransformRules.norEduPersonNIN = $AllTransformRules.norEduPersonNIN
    $TransformRules.eduPersonAssurance = $AllTransformRules.eduPersonAssurance

    $IssuanceTransformRuleCategories.Add("entity-category-sfs-1993-1153",$TransformRules)

    return $IssuanceTransformRuleCategories
}


# SIG # Begin signature block
# MIIUJwYJKoZIhvcNAQcCoIIUGDCCFBQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyHKfwokMi1Z+5ZGFJiDEByQO
# /HOggg8nMIIEmTCCA4GgAwIBAgIPFojwOSVeY45pFDkH5jMLMA0GCSqGSIb3DQEB
# BQUAMIGVMQswCQYDVQQGEwJVUzELMAkGA1UECBMCVVQxFzAVBgNVBAcTDlNhbHQg
# TGFrZSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxITAfBgNV
# BAsTGGh0dHA6Ly93d3cudXNlcnRydXN0LmNvbTEdMBsGA1UEAxMUVVROLVVTRVJG
# aXJzdC1PYmplY3QwHhcNMTUxMjMxMDAwMDAwWhcNMTkwNzA5MTg0MDM2WjCBhDEL
# MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UE
# BxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKjAoBgNVBAMT
# IUNPTU9ETyBTSEEtMSBUaW1lIFN0YW1waW5nIFNpZ25lcjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAOnpPd/XNwjJHjiyUlNCbSLxscQGBGue/YJ0UEN9
# xqC7H075AnEmse9D2IOMSPznD5d6muuc3qajDjscRBh1jnilF2n+SRik4rtcTv6O
# KlR6UPDV9syR55l51955lNeWM/4Og74iv2MWLKPdKBuvPavql9LxvwQQ5z1IRf0f
# aGXBf1mZacAiMQxibqdcZQEhsGPEIhgn7ub80gA9Ry6ouIZWXQTcExclbhzfRA8V
# zbfbpVd2Qm8AaIKZ0uPB3vCLlFdM7AiQIiHOIiuYDELmQpOUmJPv/QbZP7xbm1Q8
# ILHuatZHesWrgOkwmt7xpD9VTQoJNIp1KdJprZcPUL/4ygkCAwEAAaOB9DCB8TAf
# BgNVHSMEGDAWgBTa7WR0FJwUPKvdmam9WyhNizzJ2DAdBgNVHQ4EFgQUjmstM2v0
# M6eTsxOapeAK9xI1aogwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2Ny
# bC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0LmNybDA1BggrBgEF
# BQcBAQQpMCcwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20w
# DQYJKoZIhvcNAQEFBQADggEBALozJEBAjHzbWJ+zYJiy9cAx/usfblD2CuDk5oGt
# Joei3/2z2vRz8wD7KRuJGxU+22tSkyvErDmB1zxnV5o5NuAoCJrjOU+biQl/e8Vh
# f1mJMiUKaq4aPvCiJ6i2w7iH9xYESEE9XNjsn00gMQTZZaHtzWkHUxY93TYCCojr
# QOUGMAu4Fkvc77xVCf/GPhIudrPczkLv+XZX4bcKBUCYWJpdcRaTcYxlgepv84n3
# +3OttOe/2Y5vqgtPJfO44dXddZhogfiqwNGAwsTEOYnB9smebNd0+dmX+E/CmgrN
# Xo/4GengpZ/E8JIh5i15Jcki+cPwOoRXrToW9GOUEB1d0MYwggUZMIIEAaADAgEC
# AhANucYRs6r/dGB7AgZevKrFMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xNDEx
# MTgxMjAwMDBaFw0yNDExMTgxMjAwMDBaMG0xCzAJBgNVBAYTAk5MMRYwFAYDVQQI
# Ew1Ob29yZC1Ib2xsYW5kMRIwEAYDVQQHEwlBbXN0ZXJkYW0xDzANBgNVBAoTBlRF
# UkVOQTEhMB8GA1UEAxMYVEVSRU5BIENvZGUgU2lnbmluZyBDQSAzMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAquLnIC+sEJX6zSTl+KDf9aKtn7yzyeH4
# H8Q+5JZBbbvnA/AMFHG9pjhRt1A5pzn2Qm3iXMSe/6t41b1nAyHpbgTMRt/FhySU
# n/3WLAVhg5Oy9eF3ZCq61VDzttpv0Iu8fz5rAO5cszS/UMD4yPB9V350CkivbUhM
# i2+KXiO+dstdhHhWO4hnm9GIYKIIRAeIiabD8twq4HNswpuEJvcUPotKqGkI9JOJ
# 6B9p67QqdTILGY98swy4WuRGtGRrx9BQm/CAtE81cZ8gf1nIVGbszTMT3wkyhRAC
# YWg8tJIkYLqg0ry1xwe9/FDqNGAIHwKhjx+3LP1apkmAuTn6WUn5GQIDAQABo4IB
# uzCCAbcwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1Ud
# HwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwPQYDVR0gBDYwNDAyBgRVHSAA
# MCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHQYD
# VR0OBBYEFDIKwQzBaD5XqC35eSLljpzpRI4yMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQBErVAKGa8D4fOknsozyzRE
# lbTq3fi5SLXlapnDtwGOrtXEcx59Wgj9Gb8gTMUBu8iy2xDJ2SsN3c5xPNxbrrln
# S++9sESYuGEp3Kh6c7IUvXQ/MFzDecAM9Fbcs/7hiXhFpYfoWSiPRIttBj+xNsQw
# 7nRsVMvEA9dveBrjbEN2FUaeIklZl0043htM0nyWG/y61+l6GDAXLNWGiS7Qmhk+
# NfLGK75RSWdJHWUhr0IiTg1NDxoC6ZuCduf8irB7dVZN6j+QD4onBFUwE3pTof72
# XqL2STlUXwPJi2o1zjCoAuBAFe0VlRAdBmPv742jmuHBWmCaMYSXufCLkCpqy8ci
# MIIFaTCCBFGgAwIBAgIQCW5rqoS6iEaBVRWKc8qoWDANBgkqhkiG9w0BAQsFADBt
# MQswCQYDVQQGEwJOTDEWMBQGA1UECBMNTm9vcmQtSG9sbGFuZDESMBAGA1UEBxMJ
# QW1zdGVyZGFtMQ8wDQYDVQQKEwZURVJFTkExITAfBgNVBAMTGFRFUkVOQSBDb2Rl
# IFNpZ25pbmcgQ0EgMzAeFw0xNjA5MTkwMDAwMDBaFw0xOTA5MjQxMjAwMDBaMIG1
# MQswCQYDVQQGEwJTRTEXMBUGA1UECAwOw5ZzdGVyZ8O2dGxhbmQxEzARBgNVBAcM
# CkxpbmvDtnBpbmcxIDAeBgNVBAoMF0xpbmvDtnBpbmdzIHVuaXZlcnNpdGV0MQ4w
# DAYDVQQLEwVMSVVJVDEgMB4GA1UEAwwXTGlua8O2cGluZ3MgdW5pdmVyc2l0ZXQx
# JDAiBgkqhkiG9w0BCQEWFWpvaGFuLnBldGVyc29uQGxpdS5zZTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAK+Gsc63+pniTFtRgCwTDWvLlWnDFmsBxmfA
# folhD2l9rx3Gwmn/GAFS5xW64kIacL80T+iMc89qe/7ozmvlU9Yhj0qz4pxayV8j
# TrOXsyFkKsMkyE5WauK1yEwBMspXsmCUejV5FX+KB8S1lbUtwVVTVe8vLDWBRxIU
# mTMgMpgi/askOlAJQkhQ3CgUSWv00SwSbjORZZ2FzojmOs3ckRZU0nIrGRY4heXK
# s7Q7TxlpL/OeEJs2FfzMWP+zEvVrTGUd/hmlM08a2luZXfPQfzaPh33WUs6IEusg
# +3bQOQfNEHZcvfiB3r1gVUKT87Hz3dhrnTJ9P7soG+kRbIDCoAsCAwEAAaOCAbow
# ggG2MB8GA1UdIwQYMBaAFDIKwQzBaD5XqC35eSLljpzpRI4yMB0GA1UdDgQWBBQK
# ll4K2UPnGSzavcxKfSUdFklTVDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYI
# KwYBBQUHAwMwewYDVR0fBHQwcjA3oDWgM4YxaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL1RFUkVOQUNvZGVTaWduaW5nQ0EzLmNybDA3oDWgM4YxaHR0cDovL2NybDQu
# ZGlnaWNlcnQuY29tL1RFUkVOQUNvZGVTaWduaW5nQ0EzLmNybDBMBgNVHSAERTBD
# MDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2Vy
# dC5jb20vQ1BTMAgGBmeBDAEEATB2BggrBgEFBQcBAQRqMGgwJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBABggrBgEFBQcwAoY0aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL1RFUkVOQUNvZGVTaWduaW5nQ0EzLmNydDAMBgNV
# HRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQA//uISIy+v0S1UH1b6zWFhgFPw
# wZvtAi+WzDYlfNHM1ZKQNdGbdU5uwFnaToPoX3z5UzDEv1hOXLgCLtI3rNnj0O0J
# BaWiLtNYYeRwAV3dDpHcAbiHvViMbxIA4zCeckmxoe0HrmKs1CFCPVYM5aLXjmEP
# aWPf2GZ6xC65g85M2aE8tFNMTOFmhZ/MiiMXNYGMT78L7yKDly59+iFbJZioBnss
# ktKo+s73Cgp+PbXB0/ylQ3G7xpDeiaN0i55S/OtMbKg2lZu6RdQQwzmpfUHu8VbI
# fOnfwNPY8o+OJaWl7fJDDzuFnbFnszFD1sN8eIQXf+yOxzrPw205ka7Z2SYSMYIE
# ajCCBGYCAQEwgYEwbTELMAkGA1UEBhMCTkwxFjAUBgNVBAgTDU5vb3JkLUhvbGxh
# bmQxEjAQBgNVBAcTCUFtc3RlcmRhbTEPMA0GA1UEChMGVEVSRU5BMSEwHwYDVQQD
# ExhURVJFTkEgQ29kZSBTaWduaW5nIENBIDMCEAlua6qEuohGgVUVinPKqFgwCQYF
# Kw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFJrmdPhvse0GbvTwPYFoMlnFPPOgMA0GCSqGSIb3DQEBAQUA
# BIIBAEQZC2jpTYCRUfZbfQUTdEwjj8f5qGWT6f0Xlx8LDplmaRE6b+UHqQ6PpqJI
# ZP70F3JWibAbMsDqu8/k72WpRhf4pD82H/jz0XHT20ie/p3LWr11Xa0ctAJlqTgF
# YkaZHWwNI+jLYu3ZadunSghc2CN3lHUM4gs9v9iIiUvJpODc7DmSOXYI778Akpuo
# eZAwqX+5thn9hfE5YE7fWF/qzH85Hm6TT7cf+IPh9x4ykTLHWwBK57Gpv8hQGR9E
# /beRDgy0EAx+lW9mM7Gapi+NW/2AxDbkQmgy9eVraB5A+/dhc4LZuUQI5M9tPaql
# SJ3xeDxD169ELSr99fMmVOXv2EWhggJDMIICPwYJKoZIhvcNAQkGMYICMDCCAiwC
# AQEwgakwgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2Fs
# dCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8G
# A1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNF
# UkZpcnN0LU9iamVjdAIPFojwOSVeY45pFDkH5jMLMAkGBSsOAwIaBQCgXTAYBgkq
# hkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNzEwMTgyMjI5
# MDhaMCMGCSqGSIb3DQEJBDEWBBTAZ4I/2kh/YENGM9Vh+79p93fKvzANBgkqhkiG
# 9w0BAQEFAASCAQCgOZHNo9ZVgAmF546M7AW9kcnDBj0pdYap9xcOZmoikTYZoiyR
# 4xr7pRDgDY1CRNnr7K3byz+VBxRkkq1olsEIkzTUUb0M7joQrFOSrr3zelQL6oTQ
# +S3lz9RENVR9SSALXuMVMv/UCAV6DAn6xq2ZpdMKVI0lD3Hma+Q58NvolZv8LoR+
# UQuteogpaBhUTDmFzD9vyLxMC1Kj4MMW2JgW6I1Un5IXMh/j6ZA77s4ZHTFmM5hx
# MBXQcN++VR8aMW++HkB2EIdf5PBsVCka6kdRySK9qwS24LaFFe6+p3VFemQYyJ5M
# 4dF7yBtFFfD5B4Gi09rcfcFpAtzuOq1Ml0e1
# SIG # End signature block
