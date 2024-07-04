function Update-ADFSTkInstitutionConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [xml]$config, #Institution Config XML
        $configFile, #Institution Config file object
        [xml]$defaultFederationConfig,
        [xml]$defaultConfig
    )

#region Functions
function Update-ADFSTkXML {
    param (
        $XPath,
        $ExampleValue
    )

    $params = @{
        XPath        = $XPath
        ExampleValue = $ExampleValue 
        NewConfig    = $config
    }
    
    $defaultFederationConfigNode = $null

    if (![string]::IsNullOrEmpty($defaultFederationConfig)) {
        $defaultFederationConfigNode = Select-Xml -Xml $defaultFederationConfig -XPath $XPath
    }

    if ([string]::IsNullOrEmpty($defaultFederationConfigNode)) {
        $params.DefaultConfig = $defaultConfig
    }
    else {
        $params.DefaultConfig = $defaultFederationConfig
    }

    Set-ADFSTkConfigItem @params
}

function Remove-ADFSTkXML {
    param (
        $XPath
    )

    $node = $config.SelectSingleNode($XPath)
    if (![string]::IsNullOrEmpty($node)) {
        $node.ParentNode.RemoveChild($node) | Out-Null
    }
}
#endregion

    if (!$PSBoundParameters.ContainsKey('config')) {
        Write-ADFSTkLog (Get-ADFSTkLanguageText confNoInstConfigFileSelectedborting) -MajorFault
    }

    #Create result object
    $resultObject = [PSCustomObject]@{
        Result      = $false
        RemoveCache = $false
    }

    #Load the eventlog
    if ([string]::IsNullOrEmpty((Write-ADFSTkLog -GetEventLogName))) {
        $Settings = $config
        if (Verify-ADFSTkEventLogUsage) {
            #If we evaluated as true, the eventlog is now set up and we link the WriteADFSTklog to it
            Write-ADFSTkLog -SetEventLogName $config.configuration.logging.LogName -SetEventLogSource $config.configuration.logging.Source

        }
    }

       
    if ($config.configuration.ConfigVersion -eq $Global:ADFSTkCompatibleInstitutionConfigVersion) {
        Write-ADFSTkLog (Get-ADFSTkLanguageText confInstConfAlreadyCorrectVersion -f 'Institution config file', $Global:ADFSTkCompatibleInstitutionConfigVersion) -EntryType Information
    }
    else {
        $oldConfigVersion = $config.configuration.ConfigVersion
        $configFileObject = Get-ChildItem $configFile.configFile

        #Check if the config is enabled and disable it if so
        if ($configFile.Enabled) {
            Write-ADFSTkHost confInstitutionConfigEnabledWarning -Style Attention
            Set-ADFSTkInstitutionConfiguration -ConfigurationItem $configFile.configFile -Status Disabled
        }

        #First take a backup of the current file
        if (!(Test-Path $Global:ADFSTkPaths.institutionBackupDir)) {
            Write-ADFSTkVerboseLog -Message (Get-ADFSTkLanguageText cFileDontExist -f $Global:ADFSTkPaths.institutionBackupDir)

            New-Item -ItemType Directory -Path $Global:ADFSTkPaths.institutionBackupDir | Out-Null
                
            Write-ADFSTkVerboseLog -Message (Get-ADFSTkLanguageText cCreated)
        }
                
        $backupFilename = "{0}_backup_v{3}_{1}{2}" -f $configFileObject.BaseName, (Get-Date).tostring("yyyyMMdd_HHmmss"), $configFile.Extension, $config.configuration.ConfigVersion
        $backupFile = Join-Path $Global:ADFSTkPaths.institutionBackupDir $backupFilename
        Copy-Item -Path $configFile.configFile -Destination $backupFile | Out-Null

        Write-ADFSTkLog (Get-ADFSTkLanguageText confOldConfBackedUpTo -f $backupFile) -ForegroundColor Green

        ###Now lets upgrade in steps!###
                
        $resultObject.RemoveCache = $false

        #v0.9 --> v1.0
        $currentVersion = '0.9'
        $newVersion = '1.0'
        if ($config.configuration.ConfigVersion -eq $currentVersion) {
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confUpdatingInstConfigFromTo -f $currentVersion, $newVersion)
                    
            if ($config.configuration.LocalRelyingPartyFile -eq $null) {
                Add-ADFSTkXML -Xml $config -XPathParentNode "configuration" -NodeName "LocalRelyingPartyFile" -RefNodeName "MetadataCacheFile"
            }
                   
            Update-ADFSTkXML -XPath "configuration/LocalRelyingPartyFile" -ExampleValue 'get-ADFSTkLocalManualSPSettings.ps1'

            $config.configuration.ConfigVersion = $newVersion
            $config.Save($configFile.configFile);
        }
        #v1.0 --> v1.1
        $currentVersion = '1.0'
        $newVersion = '1.1'
        if ($config.configuration.ConfigVersion -eq $currentVersion) {
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confUpdatingInstConfigFromTo -f $currentVersion, $newVersion)
                    
            if ($config.configuration.eduPersonPrincipalNameRessignable -eq $null) {
                Add-ADFSTkXML -Xml $config -XPathParentNode "configuration" -NodeName "eduPersonPrincipalNameRessignable" -RefNodeName "MetadataPrefixSeparator"
            }
                   
            Update-ADFSTkXML -XPath "configuration/eduPersonPrincipalNameRessignable" -ExampleValue 'true/false'

            $config.configuration.ConfigVersion = $newVersion
            $config.Save($configFile.configFile);

            if ($resultObject.RemoveCache -eq $false) {
                $resultObject.RemoveCache = $true
                Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confCacheNeedsToBeRemoved)
            }
        }

        #v1.1 --> v1.2
        $currentVersion = '1.1'
        $newVersion = '1.2'
        if ($config.configuration.ConfigVersion -eq $currentVersion) {
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confUpdatingInstConfigFromTo -f $currentVersion, $newVersion)
                    
            Remove-ADFSTkXML -XPath 'configuration/WorkingPath'
            Remove-ADFSTkXML -XPath 'configuration/ConfigDir'
            Remove-ADFSTkXML -XPath 'configuration/CacheDir'

            foreach ($store in $config.configuration.storeConfig.stores.store) {
                if ([string]::IsNullOrEmpty($store.storetype)) {
                    $store.SetAttribute('storetype', $store.name)

                    'issuer', 'type', 'order' | % {
                        $attributeValue = $store.$_
                        if (![string]::IsNullOrEmpty($attributeValue)) {
                            $store.RemoveAttribute($_)
                            $store.SetAttribute($_, $attributeValue)
                        }
                    }
                }
            }

            $config.configuration.ConfigVersion = $newVersion
            $config.Save($configFile.configFile);
        }

        #v1.2 --> v1.3
        $currentVersion = '1.2'
        $newVersion = '1.3'
        if ($config.configuration.ConfigVersion -eq $currentVersion) {
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confUpdatingInstConfigFromTo -f $currentVersion, $newVersion)

            if (![string]::IsNullOrEmpty($config.configuration.storeConfig.transformRules)) {
                Write-ADFSTkLog (Get-ADFSTkLanguageText confMoveNodeFromStoreConfigToConfig -f 'transformRules')
                $config.configuration.AppendChild($config.configuration.storeConfig.transformRules) | Out-Null
            }

            if (![string]::IsNullOrEmpty($config.configuration.storeConfig.attributes)) {
                Write-ADFSTkLog (Get-ADFSTkLanguageText confMoveNodeFromStoreConfigToConfig -f 'attributes')
                $config.configuration.AppendChild($config.configuration.storeConfig.attributes) | Out-Null
            }

            $commonName = $config.configuration.attributes.attribute | ? type -eq "http://schemas.xmlsoap.org/claims/CommonName"
            if ($commonName.store -eq "Active Directory" -and $commonName.name -eq "cn") {
                Write-ADFSTkHost confChangeCommonNameToDisplayName
                if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDoYouWantToChangeCommonName) -DefaultYes) {
                    $commonName.name = "displayname"
                    Write-ADFSTkLog (Get-ADFSTkLanguageText confCommonNameChangedFromCnToDisplayName)
                }
            }

            $config.configuration.ConfigVersion = $newVersion
            $config.Save($configFile.configFile);
        }

        #v1.3 --> v1.4
        $currentVersion = '1.3'
        $newVersion = '1.4'
        if ($config.configuration.ConfigVersion -eq $currentVersion) {
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confUpdatingInstConfigFromTo -f $currentVersion, $newVersion)

            #Two attributes are added from Defaul Config below
            #Nothing else is needed
                    
            $config.configuration.ConfigVersion = $newVersion
            $config.Save($configFile.configFile);
            $resultObject.Result = $true
        }

        Write-ADFSTkLog (Get-ADFSTkLanguageText confUpdatedInstConfigDone -f $configFile.configFile, $oldConfigVersion, $Global:ADFSTkCompatibleInstitutionConfigVersion) -EntryType Information
    }

    #Add any new attributes from Default Config or Default Federation Config to the Institution Config
    if ([string]::IsNullOrEmpty($defaultFederationConfig)) {
        #Compare Default Config
        $compare = Compare-ADFSTkObject $defaultConfig.configuration.attributes.attribute.Type $config.configuration.attributes.attribute.Type -CompareType InFirstSetOnly
        if (![string]::IsNullOrEmpty($compare.CompareSet)) {
            foreach ($type in $compare.CompareSet) {
                $xmlNode = $defaultConfig.configuration.attributes.attribute | ? type -eq $type
                Add-ADFSTkXMLNode -XML $config -XPathParentNode 'configuration/attributes' -Node $xmlNode
            }
            $config.Save($configFile.configFile);
            $resultObject.Result = $true
            Write-ADFSTkLog (Get-ADFSTkLanguageText confAddedAttributeToInstitutionConfig -f ($compare.CompareSet -join [System.Environment]::NewLine)) -EventID 45 -EntryType Information
        }
    }
    else {
        #Compare Default Federation
        $compare = Compare-ADFSTkObject $defaultFederationConfig.configuration.attributes.attribute.Type $config.configuration.attributes.attribute.Type -CompareType InFirstSetOnly
        if (![string]::IsNullOrEmpty($compare.CompareSet)) {
            foreach ($type in $compare.CompareSet) {
                $xmlNode = $defaultFederationConfig.configuration.attributes.attribute | ? type -eq $type
                Add-ADFSTkXMLNode -XML $config -XPathParentNode 'configuration/attributes' -Node $xmlNode
            }
            $config.Save($configFile.configFile);
            $resultObject.Result = $true
            Write-ADFSTkLog (Get-ADFSTkLanguageText confAddedAttributeToInstitutionConfig -f ($compare.CompareSet -join [System.Environment]::NewLine)) -EventID 45 -EntryType Information
        }
    }
}

Write-ADFSTkLog (Get-ADFSTkLanguageText confUpdatedInstConfigAllDone) -EntryType Information

return $resultObject
# }


# function Add-ADFSTkXML {
#     param (
#         $NodeName,
#         $XPathParentNode,
#         $RefNodeName,
#         $Value = [string]::Empty
#     )

#     $configurationNode = Select-Xml -Xml $config -XPath $XPathParentNode
#     $configurationNodeChild = $config.CreateNode("element", $NodeName, $null)
#     $configurationNodeChild.InnerText = $Value

#     #$configurationNode.Node.AppendChild($configurationNodeChild) | Out-Null
#     $refNode = Select-Xml -Xml $config -XPath "$XPathParentNode/$RefNodeName"
#     if ($refNode -is [Object[]]) {
#         $refNode = $refNode[-1]
#     }
#     $configurationNode.Node.InsertAfter($configurationNodeChild, $refNode.Node) | Out-Null
# }

# function Add-ADFSTkXMLNode {
#     param (
#         $XPathParentNode,
#         $Node
#     )
    
#     $configurationNode = Select-Xml -Xml $config -XPath $XPathParentNode
#     $configurationNode.Node.AppendChild($config.ImportNode($Node, $true)) | Out-Null
# }

