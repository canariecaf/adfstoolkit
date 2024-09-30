#
# Module manifest for module 'ADFSToolkit'
#
# Generated by: Chris Phillips chris.phillips@canarie.ca
#
# Generated on: 11/24/2017
# v1.0.0.0  on: 04/17/2018
# v2.0.0    on: 12/17/2020
# v2.0.1    on: 03/10/2021
# v2.1.0-RC1  : 11/15/2021
# v2.1.0-RC2  : 12/03/2021
# v2.1.0-RC3  : 02/01/2022
# v2.1.0-RC4  : 03/31/2022
# v2.1.0      : 05/18/2022
# v2.2.0-RC1  : 09/27/2022
# v2.2.0-RC2  : 10/13/2022
# v2.2.0      : 10/18/2022
# v2.2.1      : 11/28/2022
# v2.3.0-RC1  : 09/14/2023
# v2.3.0-RC2  : 09/18/2024
# v2.3.0-RC3  : 09/30/2024
@{

# Script module or binary module file associated with this manifest.
RootModule = 'ADFSToolkit.psm1'

# Version number of this module. See line 125 for PreReleaes designations where an empty value is 'released'
ModuleVersion = '2.3.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '47b8b820-ef33-4f09-9a64-272fd1f1c808'

# Author of this module
Author = 'Chris Phillips, Johan Peterson and Tommy Larsson'

# Company or vendor of this module
CompanyName = 'CANARIE and SWAMID'

# Copyright statement for this module
Copyright = '(c) 2017-2020 Chris Phillips CANARIE, Johan Peterson and Tommy Larsson SWAMID http://www.apache.org/licenses/LICENSE-2.0'

# Description of the functionality provided by this module
Description = 'Module to handle SAML2 federation aggregates.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @("Initialize-ADFSTk.ps1")

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Import-ADFSTkMetadata', 'New-ADFSTkConfiguration', 'Unpublish-ADFSTkAggregate', 'Get-ADFSTkTransformRuleObjects', 'Update-ADFSTkInstitutionConfiguration', 'Sync-ADFSTkAggregates', 'New-ADFSTkInstitutionConfiguration', 'Enable-ADFSTkInstitutionConfiguration', 'Disable-ADFSTkInstitutionConfiguration', 'Get-ADFSTkToolsIssuanceTransformRules', 'Get-ADFSTkHealth', 'Get-ADFSTkPaths', 'Get-ADFSTkFederationDefaults', 'Remove-ADFSTkCache', 'Copy-ADFSTkToolRules', 'Get-ADFSTkToolEntityId', 'Install-ADFSTkMFAAdapter','Uninstall-ADFSTkMFAAdapter','Get-ADFSTkMFAAdapter','Get-ADFSTkEntityHash','Remove-ADFSTkEntityHash','Get-ADFSTkMetadata', 'Get-ADFSTkHealth', 'Register-ADFSTkScheduledTask', 'Get-ADFSTkToolSpInfoFromMetadata', 'Install-ADFSTkStore', 'Uninstall-ADFSTkStore', 'Get-ADFSTkStore', 'Get-ADFSTkLoginEvents','Invoke-ADFSTkFticks', 'Register-ADFSTkFticksScheduledTask', 'Update-ADFSTkConfiguration', 'Set-ADFSTkFticksServer', 'New-ADFSTkStateConfiguration', 'Get-ADFSTkToolIdPInfoFromMetadata', 'Get-ADFSTkStateConfiguration', 'Update-ADFSTk'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
#CmdletsToExport = @(Import-Metadata)
CmdletsToExport = '*'
# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('ADFS','SAML2','SAML', 'Federation' ,'Aggregates','CANARIE','CAF','FIMS','SWAMID','ADFSToolkit','MFA','REFEDS-MFA','REFEDS','REFEDSMFA')

        # A URL to the license for this module.
         LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/fedtools/adfstoolkit'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        Prerelease = 'RC3'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
