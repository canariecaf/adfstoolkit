

function Get-ADFSTkMFAAdapter {
    param (
        [switch]$ReturnAsObject
    )

    try {
        $authProviders = Get-AdfsAuthenticationProvider
    }
    catch {
        Write-ADFSTkHost "Could not retrieve the authentication providers." -MajorFault
    }

    $nameMFA = "RefedsMFAUsernamePasswordAdapter"
    $nameSFA = "RefedsSFAUsernamePasswordAdapter"

    $binPath = Join-Path $global:ADFSTkPaths.modulePath Bin
    $SourceDll = Join-Path $binPath 'ADFSToolkitAdapters.dll'

    $GACMainPath = 'C:\Windows\Microsoft.NET\assembly\GAC_MSIL\ADFSToolkitAdapters'
    $GACPath = Get-ChildItem -Path $GACMainPath -Recurse -Filter 'ADFSToolkitAdapters.dll' -ErrorAction SilentlyContinue

    if (Test-Path $SourceDll) {
        $SourceDllVersion = [Reflection.Assembly]::Load([IO.File]::ReadAllBytes($SourceDll)).GetCustomAttributes("System.Reflection.AssemblyFileVersionAttribute" , $true).Version
    }

    foreach ($InstalledDll in $GACPath) {
        $InstalledDllVersion = [Reflection.Assembly]::Load([IO.File]::ReadAllBytes($InstalledDll.FullName)).GetCustomAttributes("System.Reflection.AssemblyFileVersionAttribute" , $true).Version
    }

    if ($PSBoundParameters.ContainsKey('ReturnAsObject') -and $ReturnAsObject -ne $false) {
        return [PSCustomObject]@{
            RefedsMFA           = $authProviders.Name.Contains($nameMFA)
            RefedsSFA           = $authProviders.Name.Contains($nameSFA)
            SourceDllVersion    = $SourceDllVersion
            InstalledDllVersion = $InstalledDllVersion
        }
    }
    else {
        if ($authProviders.Name.Contains($nameMFA)) {
            Write-ADFSTkHost mfaAdapterPresent -f 'RefedsMFA', 'IS' -ForegroundColor Green
        }
        else {
            Write-ADFSTkHost mfaAdapterPresent -f 'RefedsMFA', 'IS NOT' -ForegroundColor Red
        }
    
        if ($authProviders.Name.Contains($nameSFA)) {
            Write-ADFSTkHost mfaAdapterPresent -f 'RefedsSFA', 'IS' -ForegroundColor Green
        }
        else {
            Write-ADFSTkHost mfaAdapterPresent -f 'RefedsSFA', 'IS NOT' -ForegroundColor Red
        }
    }
    
}