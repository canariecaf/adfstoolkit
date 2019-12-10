function Get-ADFSTkIssuanceTransformRules
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
    $RequestedAttribute,
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
    $RegistrationAuthority,
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
    $NameIDFormat
)


$AllAttributes = Import-ADFSTkAllAttributes
$AllTransformRules = Import-ADFSTkAllTransformRules

#Add posibility to have manual transform rules


$IssuanceTransformRuleCategories = Import-ADFSTkIssuanceTransformRuleCategories -RequestedAttribute $RequestedAttribute -NameIDFormat $NameIDFormat
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
                foreach ($Attribute in $IssuanceTransformRuleCategories[$_][$Rule].Attribute) { 
                    $AttributesFromStore[$Attribute] = $AllAttributes[$Attribute]
                }
            }
        }
    }
}
#endregion

#AllSPs
if ($ManualSPSettings.ContainsKey('urn:adfstk:allsps'))
{
    foreach ($Rule in $ManualSPSettings['urn:adfstk:allsps'].TransformRules.Keys) { 
        if ($ManualSPSettings['urn:adfstk:allsps'].TransformRules[$Rule] -ne $null)
        {                
            $IssuanceTransformRules[$Rule] = $ManualSPSettings['urn:adfstk:allsps'].TransformRules[$Rule].Rule.Replace("[ReplaceWithSPNameQualifier]",$EntityId)
            foreach ($Attribute in $ManualSPSettings['urn:adfstk:allsps'].TransformRules[$Rule].Attribute) { 
                $AttributesFromStore[$Attribute] = $AllAttributes[$Attribute]
            }
        }
    }
}

#AllEduSPs

if ($EntityId -ne $null)
{
    
    #First remove http:// or https://
    $entityDNS = $EntityId.ToLower().Replace('http://','').Replace('https://','')

    #Second get rid of all ending sub paths
    $entityDNS = $entityDNS -split '/' | select -First 1

    #Last fetch the last two words and join them with a .
    #$entityDNS = ($entityDNS -split '\.' | select -Last 2) -join '.'

    $settingsDNS = $null

    foreach($setting in $ManualSPSettings.Keys)
    {
        if ($setting.StartsWith('urn:adfstk:entityiddnsendswith:'))
        {
            $settingsDNS = $setting -split ':' | select -Last 1
        }
    }

    if ($entityDNS.EndsWith($settingsDNS) -and `
        $ManualSPSettings."urn:adfstk:entityiddnsendswith:$settingsDNS" -is [System.Collections.Hashtable] -and `
        $ManualSPSettings."urn:adfstk:entityiddnsendswith:$settingsDNS".ContainsKey('TransformRules'))
    {
        foreach ($Rule in $ManualSPSettings["urn:adfstk:entityiddnsendswith:$settingsDNS"].TransformRules.Keys) { 
            if ($ManualSPSettings["urn:adfstk:entityiddnsendswith:$settingsDNS"].TransformRules[$Rule] -ne $null)
            {                
                $IssuanceTransformRules[$Rule] = $ManualSPSettings["urn:adfstk:entityiddnsendswith:$settingsDNS"].TransformRules[$Rule].Rule.Replace("[ReplaceWithSPNameQualifier]",$EntityId)
                foreach ($Attribute in $ManualSPSettings["urn:adfstk:entityiddnsendswith:$settingsDNS"].TransformRules[$Rule].Attribute) { 
                    $AttributesFromStore[$Attribute] = $AllAttributes[$Attribute]
                }
            }
        }
    }
}


#Manual SP
if ($ManualSPTransformRules -ne $null)
{
    foreach ($Rule in $ManualSPTransformRules.Keys) { 
        if ($ManualSPTransformRules[$Rule] -ne $null)
        {                
            $IssuanceTransformRules[$Rule] = $ManualSPTransformRules[$Rule].Rule.Replace("[ReplaceWithSPNameQualifier]",$EntityId)
            foreach ($Attribute in $ManualSPTransformRules[$Rule].Attribute) { 
                $AttributesFromStore[$Attribute] = $AllAttributes[$Attribute]
            }
        }
    }
}

### This is a good place to remove attributes that shouldn't be sent outside a RegistrationAuthority
#$removeRules = @()
#foreach ($rule in $IssuanceTransformRules.Keys)
#{
#    $attribute = $Settings.configuration.storeConfig.attributes.attribute | ? name -eq $rule
#    if ($attribute -ne $null -and $attribute.allowedRegistrationAuthorities -ne $null)
#    {
#        $allowedRegistrationAuthorities = @()
#        $allowedRegistrationAuthorities += $attribute.allowedRegistrationAuthorities.registrationAuthority
#        if ($allowedRegistrationAuthorities.count -gt 0 -and !$allowedRegistrationAuthorities.contains($RegistrationAuthority))
#        {
#            $removeRules += $rule
#        }
#    }
#}
#
#$removeRules | % {$IssuanceTransformRules.Remove($_)}
#


$removeRules = @()
foreach ($attr in $AttributesFromStore.values)
{
    $attribute = $Settings.configuration.storeConfig.attributes.attribute | ? type -eq $attr.type
    if ($attribute -ne $null -and $attribute.allowedRegistrationAuthorities -ne $null)
    {
        $allowedRegistrationAuthorities = @()
        $allowedRegistrationAuthorities += $attribute.allowedRegistrationAuthorities.registrationAuthority
        if ($allowedRegistrationAuthorities.count -gt 0 -and !$allowedRegistrationAuthorities.contains($RegistrationAuthority))
        {
            $removeRules += $attr
        }
    }
}

$removeRules | % {
    
    $AttributesFromStore.Remove($_.type)
    foreach ($key in $AllTransformRules.Keys) 
    {
        if ($AllTransformRules.$key.Attribute -eq $_.type) 
        {
            $IssuanceTransformRules.Remove($key)
            break
        }
    }
}


###

#region Create Stores
if ($AttributesFromStore.Count)
{
    $FirstRule = ""

    foreach ($store in ($Settings.configuration.storeConfig.stores.store | sort order))
    {
        #region Active Directory Store
        if ($store.storetype -eq "Active Directory")
        {
            $currentStoreAttributes = $AttributesFromStore.Values | ? store -eq $store.name
            if ($currentStoreAttributes -ne $null)
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
        if ($store.storetype -eq "SQL")
        {
            $currentStoreAttributes = $AttributesFromStore.Values | ? store -eq $store.name
            if ($currentStoreAttributes -ne $null)
            {
                $FirstRule += @"

            @RuleName = "Retrieve Attributes from $($store.name)"
            c:[Type == "$($store.type)", Issuer == "$($store.issuer)"]
                => add(store = "$($store.name)", 
                types = ("$($currentStoreAttributes.type -join '","')"), 
                query = "$($store.query)", param = c.Value);

"@
            }
        }
        #endregion

        #region LDAP Store

        #endregion

        #region Custom Store
        if ($store.storetype -eq "Custom Store")
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