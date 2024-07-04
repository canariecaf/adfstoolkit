function Get-ADFSTkToolIdPInfoFromMetadata {
    param (
        [Parameter(Mandatory = $true,
            Position = 0)]    
        $EntityID,    
        [ValidateSet('List', 'Object', 'XML')]
        $OutputType = 'List'
    )

    $MetadataXML = Get-ADFSTkMetadata -CacheTime 60
    #$RawAllSPs = $MetadataXML.EntitiesDescriptor.EntityDescriptor | ? { $_.IDPSSODescriptor -ne $null }
    $eid = $MetadataXML.EntitiesDescriptor.EntityDescriptor | ? entityID -eq $EntityID

    if (![string]::IsNullOrEmpty($eid) -and ![string]::IsNullOrEmpty($eid.IDPSSODescriptor)) {
        if ($OutputType -eq 'XML') {
            $eid.InnerXML
        }
        else {
            $SigningCertificateString = ($eid.IDPSSODescriptor.KeyDescriptor | ? use -eq "signing"  | select -ExpandProperty KeyInfo).X509Data.X509Certificate
                
            if ($SigningCertificateString -ne $null) {
                try {
                    $SigningCertificates = @()
                    $SigningCertificateString | % {
                        $SigningCertificateBytes = [system.Text.Encoding]::UTF8.GetBytes($_)
                
                        $SigningCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2                
                        $SigningCertificate.Import($SigningCertificateBytes)
                        $SigningCertificates += $SigningCertificate
                    }
                }
                catch {}
            }

            $EncryptionCertificateString = ($eid.IDPSSODescriptor.KeyDescriptor | ? use -ne "encryption"  | select -ExpandProperty KeyInfo).X509Data.X509Certificate

            if ($EncryptionCertificateString -ne $null) {
                try {
                    $EncryptionCertificates = ""
                    $EncryptionCertificateString | % {
                        $EncryptionCertificateBytes = [system.Text.Encoding]::UTF8.GetBytes($_)
                
                        $EncryptionCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2                
                        $EncryptionCertificate.Import($EncryptionCertificateBytes)
                        
                        if ($EncryptionCertificates -eq $null) {
                            $EncryptionCertificates = $EncryptionCertificate
                        }
                        elseif ($EncryptionCertificates.NotAfter -lt $EncryptionCertificate.NotAfter) {
                            $EncryptionCertificates = $EncryptionCertificate
                        }
                    }
                }
                catch {}
            }

            $SamlEndpoints = @()
            $validEnpoints = @("urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact", "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect")
            $SamlEndpoints += $eid.IDPSSODescriptor.AssertionConsumerService | % {
                if ($validEnpoints.Contains($_.Binding)) {
                    $_.Binding
                }
            } 

            $spObject = [PSCustomObject]@{
                DisplayName           = $eid.IDPSSODescriptor.Extensions.UIInfo.DisplayName | ? lang -eq 'en' | Select -ExpandProperty '#text'
                EntityID              = $EntityID
                RegistrationAuthority = $eid.Extensions.RegistrationInfo.registrationAuthority
                EntityCategories      = $eid.Extensions.EntityAttributes.Attribute | ? Name -eq "http://macedir.org/entity-category" | Select -ExpandProperty AttributeValue | Sort
                RequestedAttributes   = $eid.IDPSSODescriptor.AttributeConsumingService.RequestedAttribute.FriendlyName | Sort
                NameIdFormat          = $eid.IDPSSODescriptor.NameIDFormat
                SigningCertificates   = $SigningCertificates
                EncryptionCertificate = $EncryptionCertificate
                SamlEndpoints         = $SamlEndpoints
                SubjectIDReq          = $eid.Extensions.EntityAttributes.Attribute | ? Name -eq "urn:oasis:names:tc:SAML:profiles:subject-id:req" | Select -First 1 -ExpandProperty AttributeValue
            }

            if ($OutputType -eq 'Object') {
                return $spObject
            }
            elseif ($OutputType -eq 'List') {
                return $spObject | Select DisplayName, `
                    EntityID , `
                    RegistrationAuthority, `
                @{Name = 'EntityCategories'; Expression = { $_.EntityCategories -join ',' } } , `
                @{Name = 'RequestedAttributes'; Expression = { $_.RequestedAttributes -join ',' } }, `
                    NameIdFormat, `
                @{Name = 'SigningCertificates'; Expression = { $_.SigningCertificates.NotAfter -join ',' } }, `
                @{Name = 'EncryptionCertificate'; Expression = { $_.EncryptionCertificate.NotAfter } }, `
                @{Name = 'SamlEndpoints'; Expression = { $_.SamlEndpoints } },
                @{Name = 'SubjectIDReq'; Expression = { $_.SubjectIDReq } }
            }
        }
    }
}