#region Functions
function Copy-ADFSTkTestConfig {
    param(
        [string]$configDescription, # Main Config
        [string]$configDirName, # SWAMID_defaultConfigFile
        [string]$configVersion, # 1.3
        [string]$configFileName, # config.ADFStk.xml
        [string]$destinationDir, # $Global:ADFSTkPaths.mainConfigFile
        [string]$ADFSToolkitTestFiles = (Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Modules\ADFSToolkit\Tests\TestFiles")
    )

    Write-Host "Copying $conficonfigDescriptiongName to ADFSToolkit module directory..." -ForegroundColor Yellow

    $federationConfigPath = Join-Path $ADFSToolkitTestFiles $configDirName

    $fromPath = Join-Path $federationConfigPath $ConfigVersion
    $fromFile = Join-Path $fromPath $configFileName

    if (!(Test-Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir -Force
    }

    Write-Host "Copying $fromFile to $destinationDir..." -NoNewline
    Copy-Item $fromFile $destinationDir -Force
    Write-Host "Done" -ForegroundColor Green
}

function Write-ADFSTkVersionText {
    param (
        $text,    
        $startVersion,
        $endVersion
    )

    Write-Host $text -NoNewline
    Write-Host $startVersion -ForegroundColor Green -NoNewline
    if ($startVersion -eq $endVersion) {
        $Color = [ConsoleColor]::Green
    }
    else {
        $Color = [ConsoleColor]::Yellow
    }
    Write-Host " ($endVersion)" -ForegroundColor $Color
}

function Invoke-ADFSTKTest {
    param (
        [string]$mainConfigVersion,
        [string]$institutionConfigVersion,
        [string]$federationConfigVersion,
        [string]$federationMainConfigVersion
    )
    
    
    #Main Config
    Copy-ADFSTkTestConfig -configDescription "Main Config" -configDirName "config.ADFSTk" -configVersion $mainConfigVersion -configFileName "config.ADFStk.xml" -destinationDir $Global:ADFSTkPaths.mainConfigDir

    #Institution Config
    Copy-ADFSTkTestConfig -configDescription "Institution Config" -configDirName "config.Swamid" -configVersion $institutionConfigVersion -configFileName "config.SWAMID.xml" -destinationDir $Global:ADFSTkPaths.institutionDir

    #Federation Config
    Copy-ADFSTkTestConfig -configDescription "Federation Config" -configDirName "SWAMID_defaultConfigFile" -configVersion $federationConfigVersion -configFileName "SWAMID_defaultConfigFile.xml" -destinationDir (Join-Path $Global:ADFSTkPaths.federationDir "SWAMID")

    #Federation entity categories
    Copy-ADFSTkTestConfig -configDescription "Federation entity categories" -configDirName "SWAMID_entityCategories" -configFileName "SWAMID_entityCategories.ps1" -destinationDir (Join-Path $Global:ADFSTkPaths.federationDir "SWAMID")

    #Federation Main Config
    Copy-ADFSTkTestConfig -configDescription "Federation Main Config" -configDirName "SWAMID_mainConfig" -configVersion $federationMainConfigVersion -configFileName "SWAMID_config.ADFSTk.xml" -destinationDir (Join-Path $Global:ADFSTkPaths.federationDir "SWAMID")

    Write-Host "Invoking test case" -ForegroundColor Yellow
    Write-Host "==================" -ForegroundColor Yellow

    Write-ADFSTkVersionText -text "Main Config Version:            " -startVersion $mainConfigVersion -endVersion $Global:ADFSTkCompatibleADFSTkConfigVersion
    Write-ADFSTkVersionText -text "Institution Config Version:     " -startVersion $institutionConfigVersion -endVersion $Global:ADFSTkCompatibleInstitutionConfigVersion
    Write-ADFSTkVersionText -text "Federation Main Config Version: " -startVersion $federationMainConfigVersion -endVersion $Global:ADFSTkCompatibleADFSTkConfigVersion
    Write-ADFSTkVersionText -text "Federation Config Version:      " -startVersion $federationConfigVersion -endVersion $Global:ADFSTkCompatibleInstitutionConfigVersion

    Remove-ADFSTkCache -FullMemoryCache

    $myNull = Read-Host "Press any key to continue..."
    Update-ADFSTk
}
#endregion

#region Initialize
$ADFSToolkitModulePath = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Modules\ADFSToolkit\ADFSToolkit"

Get-ChildItem $ADFSToolkitModulePath\Private | ForEach-Object { . $_.FullName }

$ADFSToolkitTestFiles = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Modules\ADFSToolkit\Tests\TestFiles"
# cd $ADFSToolkitTestFiless

$ADFSToolkitRootPath = "C:\ADFSToolkit"

if (Test-Path $ADFSToolkitRootPath) {
    Rename-Item -Path $ADFSToolkitRootPath -NewName "ADFSToolkit-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

Initialize-ADFSTk
#endregion

$latestInstitutionConfigVersion = $Global:ADFSTkCompatibleInstitutionConfigVersion
$latestADFSTkConfigVersion = $Global:ADFSTkCompatibleADFSTkConfigVersion

Invoke-ADFSTKTest -mainConfigVersion "1.0" -institutionConfigVersion "1.0" -federationConfigVersion $latestInstitutionConfigVersion -federationMainConfigVersion $latestADFSTkConfigVersion
if ([string]::IsNullOrEmpty((Get-ADFSTkConfiguration -ConfigFilesOnly | ? {$_.Enabled -eq $true})))
{
    Write-Host "Institution Config is disabled after upgrade..." -ForegroundColor Green
}
else
{
    Write-Host "Institution Config is not disabled after upgrade!" -ForegroundColor Red
}
$myNull = Read-Host "Press any key to continue..."

Invoke-ADFSTKTest -mainConfigVersion "1.0" -institutionConfigVersion "1.3" -federationConfigVersion $latestInstitutionConfigVersion -federationMainConfigVersion $latestADFSTkConfigVersion
$myNull = Read-Host "Press any key to continue..."

Invoke-ADFSTKTest -mainConfigVersion "1.0" -institutionConfigVersion $latestInstitutionConfigVersion -federationConfigVersion $latestInstitutionConfigVersion -federationMainConfigVersion $latestADFSTkConfigVersion
if ([string]::IsNullOrEmpty((Get-ADFSTkConfiguration -ConfigFilesOnly | ? {$_.Enabled -eq $true})))
{
    Write-Host "Institution Config were disabled even no upgrade!" -ForegroundColor Red
}
else
{
    Write-Host "Institution Config is still enabled..." -ForegroundColor Green

}
$myNull = Read-Host "Press any key to continue..."

Invoke-ADFSTKTest -mainConfigVersion "1.1 (IncorrectDefaultConfigVersion)" -institutionConfigVersion $latestInstitutionConfigVersion -federationConfigVersion "1.3" -federationMainConfigVersion $latestADFSTkConfigVersion
$myNull = Read-Host "Press any key to continue..."

Invoke-ADFSTKTest -mainConfigVersion "1.1 (CorrectDefaultConfigVersion)" -institutionConfigVersion $latestInstitutionConfigVersion -federationConfigVersion "1.3" -federationMainConfigVersion $latestADFSTkConfigVersion
$myNull = Read-Host "Press any key to continue..."

Invoke-ADFSTKTest -mainConfigVersion "1.1 (CorrectDefaultConfigVersion)" -institutionConfigVersion "1.0" -federationConfigVersion "1.3" -federationMainConfigVersion $latestADFSTkConfigVersion
