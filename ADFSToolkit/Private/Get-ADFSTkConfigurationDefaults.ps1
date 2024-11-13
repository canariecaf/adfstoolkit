function Get-ADFSTkConfigurationDefaults {
    param(
        [switch]$FederationDefault
    )

    if ($PSBoundParameters.ContainsKey('FederationDefault') -and $FederationDefault -ne $false) {
        $mainConfiguration = Get-ADFSTkConfiguration -ForceCreation
        $federationName = $mainConfiguration.Configuration.FederationConfig.Federation.FederationName
        $defaultMainFederationConfig = $null

        if (![string]::IsNullOrEmpty($federationName)) {
            $defaultFederationConfigDir = Join-Path $Global:ADFSTkPaths.federationDir $federationName

            #Check if the federation dir exists and if not, create it
            ADFSTk-TestAndCreateDir -Path $defaultFederationConfigDir -PathName "$federationName config directory"

            $DefaultMainFederationConfigFileName = Join-Path $defaultFederationConfigDir "$($federationName)_config.ADFSTk.xml"
            if (Test-Path $DefaultMainFederationConfigFileName) {
                try {
                    $defaultMainFederationConfig = $null
                    [xml]$defaultMainFederationConfig = Get-Content $DefaultMainFederationConfigFileName -ErrorAction Stop
                }
                catch {
                    Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenFederationDefaultConfig -f $DefaultMainFederationConfigFileName, $_) 
                }
            }
            else {
                Write-ADFSTkLog (Get-ADFSTkLanguageText confFederationDefaultConfigNotFound -f $DefaultMainFederationConfigFileName)
                #Ask to download Federation Defaults?
                #Try to locate the URL for the default config file
                if (![string]::IsNullOrEmpty($mainConfiguration.Configuration.FederationConfig.Federation.URL)) {
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confDownloadDefaultFederationConfig -f $mainConfiguration.Configuration.FederationConfig.Federation.URL) -DefaultYes) {
                        Get-ADFSTkFederationDefaults -URL $mainConfiguration.Configuration.FederationConfig.Federation.URL -InstallDefaults -Silent  | Out-Null
                        $defaultMainFederationConfig = Get-ADFSTkConfigurationDefaults -FederationDefault
                        # try {
                        #     $defaultMainFederationConfig = $null
                        #     [xml]$defaultMainFederationConfig = Get-Content $DefaultMainFederationConfigFileName -ErrorAction Stop
                        # }
                        # catch {
                        #     Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenFederationDefaultConfig -f $DefaultMainFederationConfigFileName, $_) 
                        # }
                    }
                    else {
                        if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confContinueWithoutDefaultFederationConfig) -DefaultYes) {
                            Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig)
                        }
                        else {
                            Write-ADFSTkLog (Get-ADFSTkLanguageText confAbortDueToIncorrectFederationConfigVersion) -MajorFault
                        }
                    }
                }
                else {
                    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confIncompatobleDefaultFederationConfig) -DefaultYes) {
                        Get-ADFSTkFederationDefaults -InstallDefaults -Silent | Out-Null
                        $defaultMainFederationConfig = Get-ADFSTkConfigurationDefaults -FederationDefault
                        # try {
                        #     [xml]$defaultMainFederationConfig = Get-Content $DefaultMainFederationConfigFileName -ErrorAction Stop
                        # }
                        # catch {
                        #     Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenFederationDefaultConfig -f $DefaultMainFederationConfigFileName, $_) 
                        # }
                    }
                    else {
                        $defaultMainFederationConfig = $null
                        if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confContinueWithoutDefaultFederationConfig) -DefaultYes) {
                            Write-ADFSTkLog (Get-ADFSTkLanguageText confContinueWithoutFederationConfig)
                        }
                        else {
                            Write-ADFSTkLog (Get-ADFSTkLanguageText confAbortDueToIncorrectFederationConfigVersion) -MajorFault
                        }
                    }
                    
                }
            }
        }
        else {
            #Ask to download Federation Name?
        }

        return $defaultMainFederationConfig
    }
    else {
        [xml]$config = New-Object System.Xml.XmlDocument
        [void]$config.AppendChild($config.CreateXmlDeclaration("1.0", "UTF-8", $null))
            
        $configurationNode = $config.CreateNode("element", "Configuration", $null)
            
        $configVersionNode = $config.CreateNode("element", "ConfigVersion", $null)
        $configVersionNode.InnerText = $Global:ADFSTkCompatibleADFSTkConfigVersion
    
        [void]$configurationNode.AppendChild($configVersionNode)
    
        $configVersionNodule = $config.CreateNode("element", "ModuleVersion", $null)
        if (![string]::IsNullOrEmpty($MyInvocation.MyCommand.Module.Version)) {
            $configVersionNodule.InnerText = $MyInvocation.MyCommand.Module.Version.ToString()
        }
    
        [void]$configurationNode.AppendChild($configVersionNodule)
    
        $OutputLanguageNode = $config.CreateNode("element", "OutputLanguage", $null)
        $OutputLanguageNode.InnerText = $Global:ADFSTkselectedLanguage
    
        [void]$configurationNode.AppendChild($OutputLanguageNode)
    
        [void]$config.AppendChild($configurationNode)
        #endregion 
    
        #region Federation config
        $federationConfig = $config.CreateNode("element", "FederationConfig", $null)
        
        $federationConfigFederation = $config.CreateNode("element", "Federation", $null)
    
        $federationConfigFederationName = $config.CreateNode("element", "FederationName", $null)
        
        if ($chosenFed -ne $null) {
            $federationConfigFederationName.InnerText = $chosenFed.Id
        }
    
        [void]$federationConfigFederation.AppendChild($federationConfigFederationName)
    
        $federationConfigFederationSigningThumbprint = $config.CreateNode("element", "SigningThumbprint", $null)
        [void]$federationConfigFederation.AppendChild($federationConfigFederationSigningThumbprint)
    
        $federationConfigFederationURL = $config.CreateNode("element", "URL", $null)
        [void]$federationConfigFederation.AppendChild($federationConfigFederationURL)
    
        [void]$federationConfig.AppendChild($federationConfigFederation)
        
        [void]$config.Configuration.AppendChild($federationConfig)
        $configFiles = $config.CreateNode("element", "ConfigFiles", $null)
        [void]$config.Configuration.AppendChild($configFiles)

        return , $config
    
        #endregion
    
    }
}