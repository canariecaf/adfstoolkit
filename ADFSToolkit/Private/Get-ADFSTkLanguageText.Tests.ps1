Describe 'Test Get-ADFSTkLanguageText' {
    BeforeAll {
        $functionName = 'Get-ADFSTkLanguageText'
        
        $modulePath = (Get-Module ADFSToolkit -ListAvailable | Select -First 1).ModuleBase
        $privateScriptsPath = Join-Path $modulePath Private
        $functionPath = Join-Path $privateScriptsPath "$functionName.ps1"
        . $functionPath

        $languagePacksPath = Join-Path $modulePath .\languagePacks
        $enUSPath = Join-Path $languagePacksPath '.\en-US'
    }
    
    Context 'Test if function is loaded' { 
        It "Test that the function is loaded" {
            Test-Path function:$functionName | Should -Be $true
        }
    }
    Context 'See if languagefiles exists' {
        It 'Test en-US pson exists' {
            $enUSPath | Should -Exist
        }
    }
    Context 'Get some standard texts' -Tag 'StandardText' {
        It "Common texts [c]" {
            Get-ADFSTkLanguageText cPressAnyKey -Language en-US | Should -Be "Press any key to continue..."
        }
        It "Main configuration cmdlets [mainconf]" {
            Get-ADFSTkLanguageText mainconfConfigFileExists -Language en-US | Should -Be "A configuration file already exists!"
        }
        It "Institution configuration cmdlets [conf]" {
            Get-ADFSTkLanguageText confNoPreviousFile -Language en-US | Should -Be "No Previous Configuration detected"
        }
        It "Federation cmdlets [federation]" {
            Get-ADFSTkLanguageText federationGettingListFromDefaultFile -Language en-US | Should -Be "Reading the federations list from default file..."
        }
        It "Default configuration" {
            Get-ADFSTkLanguageText "defaultConfiguration_configuration/metadataURL" -Language en-US | Should -Be "The URL to the federated metadata"
        }
        It "Issuance Transform Rules [rules]" {
            Get-ADFSTkLanguageText rulesFederationEntityCategoryFile -Language en-US | Should -Be "Loading Federation-specific Entity Categories..."
        }
        It "Manual SP Settings [ms]" {
            Get-ADFSTkLanguageText msNoConfiguredFile -Language en-US | Should -Be "No Manual SP Settings file configured. No attribute overrides will be processed. Update configuration file to add a Local Manual RelyingParty SP Settings file (Get-ADFSTkLocalManualSpSettings.ps1)"
        }
        It "Add Relying Party Trust [addRP]" {
            Get-ADFSTkLanguageText addRPGettingEncryptionert -Language en-US | Should -Be "Getting Token Encryption Certificate..."
        }
        It "Process Relying Party Trust [processRP]" {
            Get-ADFSTkLanguageText processRPCouldNotGetChachedEntity -Language en-US | Should -Be "Could not get cached entity or compute the hash for it..."
        }
        It "Import Metadata [import]" {
            Get-ADFSTkLanguageText importCouldNotImportSPHashFile -Language en-US | Should -Be "Could not import SP Hash File!"
        }
        It "Sync Aggregate [sync]" {
            Get-ADFSTkLanguageText syncStart -Language en-US | Should -Be "Sync-ADFSTkAggregates started!"
        }
        It "Unpublish Aggregate [unpub]" {
            Get-ADFSTkLanguageText unpubJobCompleated -Language en-US | Should -Be "Job completed!"
        }
        It "Write Log [log]" {
            Get-ADFSTkLanguageText logEventLogCreated -Language en-US | Should -Be "ADFSToolkit EventLog Created"
        }
        It "ADFSTkHealth [health]" {
            Get-ADFSTkLanguageText healthCheckSignatureStartMessage -Language en-US | Should -Be "Checking signature on module scipts..."
        }
        It "ADFSTkFederationDefaults [feddefaults]" {
            Get-ADFSTkLanguageText feddefaultsAllDone -Language en-US | Should -Be "Federation Defaults done."
        }
        It "Remove Cache [cache]" {
            Get-ADFSTkLanguageText cacheSelectedSPHashFileAreYouSure -Language en-US | Should -Be "Are you sure you want to delete the SP Hash file?"
        }
        It "Tools cmdlets [tool]" {
            Get-ADFSTkLanguageText toolSelectTarget -Language en-US | Should -Be "Select TARGET Relying Party Trust..."
        }
    }
    Context 'Get some texts with Fcormat String' -Tag 'FormatString' {
        It "Common texts [c]" {
            $random = Get-Random 
            Get-ADFSTkLanguageText cChosen -Language en-US -f $random | Should -Be "'$random' chosen!"
        }
        It "Main configuration cmdlets [mainconf]" {
            $random1 = Get-Random 
            $random2 = Get-Random 
            Get-ADFSTkLanguageText mainconfChangedSuccessfully -Language en-US -f $random1, $random2 | Should -Be "The status of '$random1' is set to '$random2'."
        }
    }
    Context 'Test missing text' -Tag 'MissingText' {
        It "Should not throw" {
            {Get-ADFSTkLanguageText ThisDoesntExist -Language en-US} | Should -Not -Throw
        }
        It "Should return this text" {
            Get-ADFSTkLanguageText ThisDoesntExist -Language en-US | Should -Be "[ErrorLanguageStringNotFound: ThisDoesntExist]"
        }
    }
}