

function Get-ADFSTkLocalManualSPSettings {

    # HOW TO USE THIS FILE
    #
    # To see examples:
    # dot source this file from the location:
    #  . C:\ADFSToolkit\config\institution\Get-ADFSTkLocalManualSpSettings.ps1
    #
    # To see examples invoke Powershell get-help: 
    #   Get-Help Get-ADFSTkLocalManualSPSettings -Examples

    # This file exists as a template in the Module with a runtime instance in: 
    #     C:\ADFSToolkit\config\institution\Get-ADFSTkLocalManualSpSettings.ps1  

    #To get help with wich attributes that are available, run the following commands:
    #(you can select the lines between <# and #> and press F8 to run them
    <#
    $md = Get-Module -Name ADFSToolkit
    . (join-path $md.ModuleBase "Private\Get-ADFSTkTransformRule.ps1")
    . (join-path $md.ModuleBase "Private\Import-ADFSTkAllTransformRules.ps1")
    $AllTransformRules = Import-ADFSTkAllTransformRules
#>       

    #region Helper Objects

    #Helper objects, do not remove!
    $SecureHashAlgorithm = @{
        SHA1   = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
        SHA256 = 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'
    }

    # Hashtable that we will return at the end of the function (ok to be empty, but MUST exist)

    $IssuanceTransformRuleManualSP = @{}

    # Hashtable containing all settings to set or override on a SP
    # Copy this to all SP's you want to configure

    # $ManualSPSettings = @{
    #     ApplyMFAConfiguration = @{AzureMFA = @{ 
    #             phoneconfirmation    = $false       # Call to phone
    #             phoneotp             = $true        # Click on number on phone
    #             phoneappnotification = $true       # Push to phone app
    #             smsotp               = $false       # OTP from SMS
    #             otp                  = $true        # OTP from phone app
    #         }
        
    #         CustomMFAConfiguration         = @{
    #             FrejaeID = "http://freja.com/mfa"
    #             BankID   = "http://bankid.se/mfa"
    #         } 
    #     }

    #    EntityCategories = @("http://www.geant.net/uri/dataprotection-code-of-conduct/v1")
    #    SamlResponseSignature = 'MessageAndAssertion' #Valid SamlResponseSignatures: AssertionOnly, MessageAndAssertion, MessageOnly
    #    CustomAccessControlPolicyName = "Permit everyone and require MFA" #The ACP needs to exist before use
    # }

    #endregion

    <#
    ### Attribute release for ALL SP:s
    
    $ManualSPSettings = @{
        TransformRules = [Ordered]@{}
    }

    $ManualSPSettings.TransformRules = [Ordered]@{}
    $ManualSPSettings.TransformRules.norEduPersonNIN = $AllTransformRules.norEduPersonNIN
    
    $IssuanceTransformRuleManualSP["urn:adfstk:allsps"] = $ManualSPSettings

    ### Attribute release for all SP:s for one institution
    
    $ManualSPSettings = @{
        TransformRules = [Ordered]@{}
    }

    $ManualSPSettings.TransformRules = [Ordered]@{}
    $ManualSPSettings.TransformRules.norEduPersonLIN = $AllTransformRules.norEduPersonLIN
    
    $IssuanceTransformRuleManualSP["urn:adfstk:entityiddnsendswith:swamid.se"] = $ManualSPSettings
    
    ### Attribute release for one specific SP

    $ManualSPSettings = @{
        TransformRules = [Ordered]@{}
    }

    $ManualSPSettings.TransformRules.schacPersonalUniqueCode = [PSCustomObject]@{
        Rule=@"
        @RuleName = "compose schacPersonalUniqueCode for [entityID]"
        c:[Type == "urn:mace:dir:attribute-def:schacPersonalUniqueCode", Value ~= "^only_release_values_starting_with_this_string"] 
         => issue(Type = "urn:oid:1.3.6.1.4.1.25178.1.2.14", 
         Value = c.Value, 
         Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
        Attribute="urn:mace:dir:attribute-def:schacPersonalUniqueCode"
        AttributeGroup="ID's"
    }

    $IssuanceTransformRuleManualSP["entityID"] = $ManualSPSettings
    #>

    # see below documentation for example Powershell code blocks to copy and paste here
  
    ######BEGIN Specific SP Attribute Release Settings
    
    # If this section is empty, there are no overrides for SPs yet -- see help above for examples
    


    
    ######END Specific SP Attribute Release Settings

    
    # Manditory: this returns the settings to whomever invoked this function
    
    $IssuanceTransformRuleManualSP

    <#
.SYNOPSIS
This is the file that site admins edit to locally control per Relying Party/Service provider attribute release.
ADFSToolkit attempts to detect the presence of variable ADFSTkSiteSPSettings and then ingest it to control specific rules.

This file, minus the digital signature, is usually used in c:\ADFSToolkit\sync-ADFSTkAggregates.ps1 
  
ExecutionPolicy: Can execute without being signed as it is locally executed. It is the site admin's discretion to permit/allow this. 


.DESCRIPTION

This file allows a site admin to configure per RP/SP attribute release policies for ADFSToolkit.
ADFSToolkit's default behaviour for Entity Categories such as Research and Scholarship are handled elsewhere in the ADFSToolkit Module.


How this Powershell Cmdlet works:

Creation of this file: 
Usually created from invocation of get-ADFSTkConfiguration or created by hand and placed in c:\ADFSToolkit\ to be dot sourced.

In the file:
 
For each entity we want to change the attribute handling policy of ADFS, we:
   -  create an empty TransformRules Hashtable
   -  assign 1 or more specific transform rules that have a corelating TransformRules Object
   -  When all transform rules are described, the set of transforms is inserted into the Hashtable we return

    Clever transforms can be used as well to supercede or inject elements into RP/SP settings. Some are detailed in the examples.

    To see example code blocks invoke detailed help by: get-help get-ADFSTkManualSPSettings -Detailed
   
.INPUTS

none

.OUTPUTS

a Powershell Hashtable structured such that ADFSToolkit may ingest and perform attribute release.

.EXAMPLE
### CAF test Federation Validator service attribute release
# $IssuanceTransformRuleManualSP = @{} uncomment when testing example. Needed only once per file to contain set of changes

$TransformRules = [Ordered]@{}
$TransformRules.givenName = $AllTransformRules.givenName
$TransformRules.sn = $AllTransformRules.sn
$TransformRules.cn = $AllTransformRules.cn
$TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
$TransformRules.mail = $AllTransformRules.mail
$TransformRules.eduPersonAffiliation = $AllTransformRules.eduPersonAffiliation
$TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
$IssuanceTransformRuleManualSP["https://validator.caftest.canarie.ca/shibboleth"] = $TransformRules

    
.EXAMPLE
### Lynda.com attribute release
# $IssuanceTransformRuleManualSP = @{} uncomment when testing example. Needed only once per file to contain set of changes

    
$TransformRules = [Ordered]@{}
$TransformRules.givenName = $AllTransformRules.givenName
$TransformRules.sn = $AllTransformRules.sn
$TransformRules.cn = $AllTransformRules.cn
$TransformRules.eduPersonPrincipalName = $AllTransformRules.eduPersonPrincipalName
$TransformRules.mail = $AllTransformRules.mail
$TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
$IssuanceTransformRuleManualSP["https://shib.lynda.com/shibboleth-sp"] = $TransformRules

.EXAMPLE
### advanced ADFS Transform rule #1 'from AD'    
# $IssuanceTransformRuleManualSP = @{} uncomment when testing example. Needed only once per file to contain set of changes

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
$IssuanceTransformRuleManualSP."advanced.entity.id.org" = $TransformRules

.EXAMPLE
### advanced ADFS Transform rule #2 
# $IssuanceTransformRuleManualSP = @{} uncomment when testing example. Needed only once per file to contain set of changes

$TransformRules = [Ordered]@{}
$TransformRules.mail = [PSCustomObject]@{
Rule=@"
@RuleName = "compose mail address as name@schacHomeOrganization"
c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", Value !~ "^.+\\"]
=> issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", Value = c.Value + "@$($Settings.configuration.StaticValues.schacHomeOrganization)");
"@
Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
     }
$IssuanceTransformRuleManualSP["https://advanced.rule.two.org"] = $TransformRules
    
.EXAMPLE
### verify-i.myunidays.com
# $IssuanceTransformRuleManualSP = @{} uncomment when testing example. Needed only once per file to contain set of changes

$TransformRules = [Ordered]@{}
$TransformRules.eduPersonScopedAffiliation = $AllTransformRules.eduPersonScopedAffiliation
$TransformRules.eduPersonTargetedID = $AllTransformRules.eduPersonTargetedID
$IssuanceTransformRuleManualSP["https://verify-i.myunidays.com/shibboleth"] = $TransformRules

.EXAMPLE
### Release just transient-id
# $IssuanceTransformRuleManualSP = @{} uncomment when testing example. Needed only once per file to contain set of changes

$TransformRules = [Ordered]@{}
$TransformRules.'transient-id' = $AllTransformRules.'transient-id'
$IssuanceTransformRuleManualSP["https://just-transientid.org"] = $TransformRules

.NOTES

Details about Research and Scholarship Entity Category: https://refeds.org/category/research-and-scholarship

#>

}
