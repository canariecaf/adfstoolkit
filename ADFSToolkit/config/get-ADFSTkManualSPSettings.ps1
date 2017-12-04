#========================================================================== 
# NAME: Import-SWAMIDManualSPBuilder.ps1
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
#   1.3        2014-05-23	Johan Peterson (adm)	Added eduPersonScopedAffiliation to hr.liu.se
#   1.4        2015-03-05	Johan Peterson (adm)	Added entity category http://refeds.org/category/research-and-scholarship
#   1.5        2015-04-24	Johan Peterson (adm)	Fixed Get-ADFSTkIssuanceTransformRules so you can use only a EntityId without EntityCategories, also changed Transient-Id to not hardcode sp.swamid.se
#   1.6        2015-04-24	Johan Peterson (adm)	Fixed Get-ADFSTkIssuanceTransformRules so it can handle entity-id not having sp.swamid.se hardcoded
#   1.7        2015-05-13	Johan Peterson (adm)	Added AeTM as ManualSP
#   1.8        2015-05-22	Johan Peterson (adm)	Fixed AeTM
#=========================================================================


function get-ADFSTkManualSPSettings
{
    $IssuanceTransformRuleManualSP = @{}

    ### hr.liu.se
    
    $TransformRules = [Ordered]@{}
    $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
    $TransformRules.norEduPersonNIN = $AllTransformRules.norEduPersonNIN
    $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
    
    $IssuanceTransformRuleManualSP["https://hr.liu.se/shibboleth"] = $TransformRules
    
    ###

    ### Visma Proceedo (LiU inköp)
        #Release custom formatted (base64) eduPersonPrincipalName to Visma Proceedo
        #www.proceedo.net
    ###

    ### careergate.liu.se (alias for SWAMID registered service graduateland.com)
        
        $TransformRules = [Ordered]@{}
        $TransformRules.givenName = $AllTransformRules.givenName
        $TransformRules.sn = $AllTransformRules.sn
        $TransformRules.displayName = $AllTransformRules.displayName
        $TransformRules.cn = $AllTransformRules.cn
        $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
        $TransformRules.uid = $AllTransformRules.uid
        $TransformRules.email = $AllTransformRules.email
        $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
        
        $IssuanceTransformRuleManualSP["http://careergate.liu.se/simplesaml/module.php/saml/sp/metadata.php/gl_gateway"] = $TransformRules
        

    ###

    ### sites.liu.se
        $TransformRules = [Ordered]@{}
        $TransformRules.givenName = $AllTransformRules.givenName
        $TransformRules.sn = $AllTransformRules.sn
        $TransformRules.displayName = $AllTransformRules.displayName
        $TransformRules.cn = $AllTransformRules.cn
        $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
        $TransformRules.email = $AllTransformRules.email
        $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation

        $IssuanceTransformRuleManualSP["https://sites.liu.se/shibboleth"] = $TransformRules

    ###

    ### akademiskahogtider.se
        $TransformRules = [Ordered]@{}
        $TransformRules.givenName = $AllTransformRules.givenName
        $TransformRules.sn = $AllTransformRules.sn
        $TransformRules.displayName = $AllTransformRules.displayName
        $TransformRules.cn = $AllTransformRules.cn
        $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
        $TransformRules.email = $AllTransformRules.email
        $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation

        $IssuanceTransformRuleManualSP["https://www.akademiskahogtider.se/shibboleth"] = $TransformRules
    ###

    ### EZproxy (Biblioteket) lt.ltag.bibl.liu.se
        $TransformRules = [Ordered]@{}
        $TransformRules.givenName = $AllTransformRules.givenName
        $TransformRules.sn = $AllTransformRules.sn
        $TransformRules.displayName = $AllTransformRules.displayName
        $TransformRules.cn = $AllTransformRules.cn
        $TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
        $TransformRules.uid = $AllTransformRules.uid
        $TransformRules.email = $AllTransformRules.email
        $TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
        
        $IssuanceTransformRuleManualSP["https://lt.ltag.bibl.liu.se/saml"] = $TransformRules
    ###

    ### bilda-dev.it.liu.se
        $TransformRules = [Ordered]@{}
        $TransformRules."From AD" = @"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", 
Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", 
types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn", 
"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", 
"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress", 
"http://liu.se/claims/eduPersonScopedAffiliation", 
"http://liu.se/claims/Department"), 
query = ";userPrincipalName,displayName,mail,eduPersonScopedAffiliation,department;{0}", param = c.Value);
"@
        
        $IssuanceTransformRuleManualSP."bilda-dev.it.liu.se" = $TransformRules
    ###

    ### Amadeus AeTM Boka resor
        $TransformRules = [Ordered]@{}
        $TransformRules."transient-id" = $AllTransformRules."transient-id"
        $TransformRules.LoginName = $AllTransformRules.LoginName
        
        $IssuanceTransformRuleManualSP["AeTM"] = $TransformRules
    ###

    ### Raindance Test
        $TransformRules = [Ordered]@{}
        $TransformRules["eduPersonPrincipalName"] = $AllTransformRules["eduPersonPrincipalName"]
        $IssuanceTransformRuleManualSP["https://liu.raindancesaas.se/rptest"] = $TransformRules


    ### Digicert
        $TransformRules = [Ordered]@{}
        $TransformRules["eduPersonPrincipalName"] = $AllTransformRules["eduPersonPrincipalName"]
        $TransformRules["displayName"] = $AllTransformRules["displayName"]
        $TransformRules["mail"] = $AllTransformRules["mail"]
        $TransformRules["schacHomeOrganization"] = $AllTransformRules["schacHomeOrganization"]
        $TransformRules["eduPersonEntitlement"] = $AllTransformRules["eduPersonEntitlement"]
        $TransformRules["eduPersonAssurance"] = $AllTransformRules["eduPersonAssurance"]
        $IssuanceTransformRuleManualSP["https://www.digicert.com/sso"] = $TransformRules
    ###

    ### Egencia Boka resor
        $TransformRules = [Ordered]@{}
        $TransformRules.mail = [PSCustomObject]@{
    Rule=@"
    @RuleName = "compose mail address as name@schacHomeOrganization"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", Value !~ "^.+\\"]
 => issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", Value = c.Value + "@$($Settings.configuration.StaticValues.schacHomeOrganization)");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    }
        
        $IssuanceTransformRuleManualSP["https://www.egencia.com/auth/v1"] = $TransformRules
    ###

    ### verify-i.myunidays.com
        $TransformRules = [Ordered]@{}
        $TransformRules["eduPersonScopedAffiliation"] = $AllTransformRules["eduPersonScopedAffiliation"]
        $TransformRules["eduPersonTargetedID"] = $AllTransformRules["eduPersonTargetedID"]
        $IssuanceTransformRuleManualSP["https://verify-i.myunidays.com/shibboleth"] = $TransformRules
    ###

    ### vartuppdrag.se
        $TransformRules = [Ordered]@{}
        $TransformRules.'transient-id' = $AllTransformRules.'transient-id'
                
        $IssuanceTransformRuleManualSP["https://vartuppdrag.se"] = $TransformRules
    ###

    $IssuanceTransformRuleManualSP
}
