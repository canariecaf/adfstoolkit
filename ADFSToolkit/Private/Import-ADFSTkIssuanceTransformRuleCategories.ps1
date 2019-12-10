function Import-ADFSTkIssuanceTransformRuleCategories {
param (
    
[Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
    $RequestedAttribute,
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
    $NameIDFormat

)
    ### Create AttributeStore variables
    $IssuanceTransformRuleCategories = @{}

    $RequestedAttributes = @{}

    if (![string]::IsNullOrEmpty($RequestedAttribute))
    {
        $RequestedAttribute | % {
            $RequestedAttributes.($_.Name.trimEnd()) = $_.friendlyName
        }
    }else
    {
    Write-ADFSTkLog "No Requested attributes detected"

    }

    ### Released to SP:s without Entity Category

    $TransformRules = [Ordered]@{}

    if ([string]::IsNullOrEmpty($NameIDFormat))
    {
        $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    }
    elseif ($NameIDFormat.Contains('urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'))
    {
        $TransformRules.'persistent-id' = $AllTransformRules.'persistent-id'
    }
    elseif ($NameIDFormat.Contains('urn:oasis:names:tc:SAML:2.0:nameid-format:transient'))
    {
        $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    }
    else
    {
        $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    }

    $IssuanceTransformRuleCategories.Add("NoEntityCategory",$TransformRules)
    
    ### research-and-scholarship ###

    $TransformRules = [Ordered]@{}

    #$TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    
    $TransformRules.displayName = $AllTransformRules.displayName
    $TransformRules.eduPersonAssurance = $AllTransformRules.eduPersonAssurance
    $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
    $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
    
    #eduPersonTargetedID should only be released if eduPersonPrincipalName i ressignable
    if (![string]::IsNullOrEmpty($Settings.configuration.eduPersonPrincipalNameRessignable) -and $Settings.configuration.eduPersonPrincipalNameRessignable.ToLower() -eq "true")
    {
        $TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID
    }

    $TransformRules.eduPersonUniqueID = $AllTransformRules.eduPersonUniqueID
    $TransformRules.givenName = $AllTransformRules.givenName
    $TransformRules.mail = $AllTransformRules.mail
    $TransformRules.sn = $AllTransformRules.sn

    $IssuanceTransformRuleCategories.Add("research-and-scholarship",$TransformRules)

    #...
    #$IssuanceTransformRuleCategories.Add("research-and-scholarship-SWAMID",$TransformRules)

    ### GEANT Dataprotection Code of Conduct
    
    $TransformRules = [Ordered]@{}

    if ($RequestedAttributes.Count -gt 0)
    {
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.6")) {
            $TransformRules.c = $AllTransformRules.c
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.3")) {
            $TransformRules.cn = $AllTransformRules.cn
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:0.9.2342.19200300.100.1.43")) {
            $TransformRules.co = $AllTransformRules.co
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.16.840.1.113730.3.1.241")) { 
            $TransformRules.displayName = $AllTransformRules.displayName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.6")) { 
            $TransformRules.countryName = $AllTransformRules.countryName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.1")) {
            $TransformRules.eduPersonAffiliation = $AllTransformRules.eduPersonAffiliation
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.11")) {
            $TransformRules.eduPersonAssurance = $AllTransformRules.eduPersonAssurance
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.16")) {
            $TransformRules.eduPersonOrcid = $AllTransformRules.eduPersonOrcid
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.6")) { 
            $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.9")) {
            $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.10")) { 
            $TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.5923.1.1.1.13")) { 
            $TransformRules.eduPersonUniqueID = $AllTransformRules.eduPersonUniqueID
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:0.9.2342.19200300.100.1.43")) { 
            $TransformRules.friendlyCountryName = $AllTransformRules.friendlyCountryName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.42")) { 
            $TransformRules.givenName = $AllTransformRules.givenName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:0.9.2342.19200300.100.1.3")) { 
            $TransformRules.mail = $AllTransformRules.mail
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.2428.90.1.6")) { 
            $TransformRules.norEduOrgAcronym = $AllTransformRules.norEduOrgAcronym 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.2428.90.1.5")) {
            $TransformRules.norEduPersonNIN = $AllTransformRules.norEduPersonNIN
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.10")) {
            $TransformRules.o = $AllTransformRules.o
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.10")) { 
            $TransformRules.organizationName = $AllTransformRules.organizationName 
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.2.752.29.4.13")) {
            $TransformRules.personalIdentityNumber = $AllTransformRules.personalIdentityNumber
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.25178.1.2.3")) {
            $TransformRules.schacDateOfBirth = $AllTransformRules.schacDateOfBirth
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.25178.1.2.9")) { 
            $TransformRules.schacHomeOrganization = $AllTransformRules.schacHomeOrganization
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:1.3.6.1.4.1.25178.1.2.10")) {
            $TransformRules.schacHomeOrganizationType = $AllTransformRules.schacHomeOrganizationType
        }
        if ($RequestedAttributes.ContainsKey("urn:oid:2.5.4.4")) { 
            $TransformRules.sn = $AllTransformRules.sn
        }
    }

    $IssuanceTransformRuleCategories.Add("ReleaseToCoCo",$TransformRules)
    
    ### SWAMID Entity Category Research and Education

    $TransformRules = [Ordered]@{}

    #$TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
    $TransformRules.eduPersonUniqueID = $AllTransformRules.eduPersonUniqueID
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

    #$TransformRules.'transient-id' = $AllTransformRules.'transient-id'
    $TransformRules.norEduPersonNIN = $AllTransformRules.norEduPersonNIN
    $TransformRules.eduPersonAssurance = $AllTransformRules.eduPersonAssurance

    $IssuanceTransformRuleCategories.Add("entity-category-sfs-1993-1153",$TransformRules)

    return $IssuanceTransformRuleCategories
}