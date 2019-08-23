<#
    .SYNOPSIS
        Public Pester function tests.
#>
[OutputType()]
Param ()

# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}
$moduleParent = Join-Path -Path $projectRoot -ChildPath $module
$manifestPath = Join-Path -Path $moduleParent -ChildPath "$module.psd1"
$modulePath = Join-Path -Path $moduleParent -ChildPath "$module.psm1"

# Import module
Write-Host ""
Write-Host "Importing module." -ForegroundColor Cyan
Import-Module $manifestPath -Force

# Read module resource strings for testing
. "$moduleParent\Private\Test-PSCore.ps1"
. "$moduleParent\Private\Get-ModuleResource.ps1"
. "$moduleParent\Private\ConvertTo-Hashtable.ps1"
$ResourceStrings = Get-ModuleResource -Path "$moduleParent\LatestUpdate.json"

InModuleScope LatestUpdate {
    Describe 'Get-LatestCumulativeUpdate' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions) {
            Write-Host ""
            Write-Host "`tBuilding variable for Windows 10 [$Version]." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestCumulativeUpdate -OperatingSystem Windows10 -Version $Version)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of Cumulative updates for Windows 10 $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                It "Returns the expected output" {
                    $Output | Should -BeOfType ((Get-Command Get-LatestCumulativeUpdate).OutputType.Type.Name)
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                        $Update.Revision | Should -BeOfType System.String
                    }
                }
            }
            Context "Returns expected results for Windows 10 $Version" {
                ForEach ($Update in $Output) {
                    It "Given $Version returns updates for version $($Version): [$($Update.Version), $($Update.Architecture)]" {
                        $Update.Note -match "$($ResourceStrings.SearchStrings.CumulativeUpdate).*$Version" | Should -Not -BeNullOrEmpty
                        $Update.Architecture -match $ResourceStrings.Architecture.All | Should -Not -BeNullOrEmpty
                        $Update.Version -match $Version | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }
    }

    Describe 'Get-LatestCumulativeUpdate -Previous' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions) {
            Write-Host ""
            Write-Host "`tBuilding variable for Windows 10 [$Version] with -Previous." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestCumulativeUpdate -OperatingSystem Windows10 -Version $Version -Previous)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of previous Cumulative updates for Windows 10 $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
        }
    }

    Describe 'Get-LatestServicingStack' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions) {
            Write-Host ""
            Write-Host "`tBuilding variable for Windows 10 [$Version]." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestServicingStack -OperatingSystem Windows10 -Version $Version)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of Servicing Stack updates for Windows 10 $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                It "Returns the expected output" {
                    $Output | Should -BeOfType ((Get-Command Get-LatestServicingStack).OutputType.Type.Name)
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
            Context "Returns expected results for Windows 10 $Version" {
                ForEach ($Update in $Output) {
                    It "Given $Version returns updates for version $($Version): [$($Update.Version), $($Update.Architecture)]" {
                        $Update.Note -match "$($ResourceStrings.SearchStrings.ServicingStack).*$Version" | Should -Not -BeNullOrEmpty
                        $Update.Architecture -match $ResourceStrings.Architecture.All | Should -Not -BeNullOrEmpty
                        $Update.Version -match $Version | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }
    }

    Describe 'Get-LatestServicingStack -Previous' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions) {
            Write-Host ""
            Write-Host "`tBuilding variable for Windows 10 [$Version] with -Previous." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestServicingStack -OperatingSystem Windows10 -Version $Version -Previous)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of previous Servicing Stack updates for Windows 10 $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
        }
    }

    Describe 'Get-LatestNetFrameworkUpdate' {
        ForEach ($Version in $ResourceStrings.ParameterValues.VersionsComplete) {
            Write-Host ""
            Write-Host "`tBuilding variable for [$Version]." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestNetFrameworkUpdate -OperatingSystem $Version)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of .NET Framework updates for $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                It "Returns the expected output" {
                    $Output | Should -BeOfType ((Get-Command Get-LatestNetFrameworkUpdate).OutputType.Type.Name)
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
            Context "Returns expected results for $Version" {
                ForEach ($Update in $Output) {
                    It "Given $Version returns updates for version $($Version): [$($Update.Version), $($Update.Architecture)]" {
                        $Update.Note -match "$($ResourceStrings.SearchStrings.NetFramework).*$Version" | Should -Not -BeNullOrEmpty
                        $Update.Architecture -match $ResourceStrings.Architecture.All | Should -Not -BeNullOrEmpty
                        $Update.Version -match $Version | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }
    }

    Describe 'Get-LatestMonthlyRollup' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Versions87) {
            Write-Host ""
            Write-Host "`tBuilding variable for [$Version]." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestMonthlyRollup -OperatingSystem $Version)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of Monthly Rollup updates for $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                It "Returns the expected output" {
                    $Output | Should -BeOfType ((Get-Command Get-LatestMonthlyRollup).OutputType.Type.Name)
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
            Context "Returns expected results for $Version" {
                ForEach ($Update in $Output) {
                    It "Given $Version returns updates for version $($Version): [$($Update.Version), $($Update.Architecture)]" {
                        $Update.Note -match "$($ResourceStrings.SearchStrings.$Version).*$Version" | Should -Not -BeNullOrEmpty
                        $Update.Architecture -match $ResourceStrings.Architecture.All | Should -Not -BeNullOrEmpty
                        $Update.Version -match $Version | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }
    }

    Describe 'Get-LatestMonthlyRollup -Previous' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Versions87) {
            Write-Host ""
            Write-Host "`tBuilding variable for [$Version] with -Previous." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestMonthlyRollup -OperatingSystem $Version -Previous)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of Monthly Rollup updates for $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
        }
    }

    Describe 'Get-LatestAdobeFlashUpdate' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions) {
            Write-Host ""
            Write-Host "`tBuilding variable for Windows 10 [$Version]." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestAdobeFlashUpdate -OperatingSystem Windows10 -Version $Version)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of Adobe Flash Player updates for Windows 10 $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                It "Returns the expected output" {
                    $Output | Should -BeOfType ((Get-Command Get-LatestAdobeFlashUpdate).OutputType.Type.Name)
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
            Context "Returns expected results for Windows 10 $Version" {
                ForEach ($Update in $Output) {
                    It "Given $Version returns updates for version $($Version): [$($Update.Version), $($Update.Architecture)]" {
                        $Update.Note -match "$($ResourceStrings.SearchStrings.AdobeFlash).*$Version" | Should -Not -BeNullOrEmpty
                        $Update.Architecture -match $ResourceStrings.Architecture.All | Should -Not -BeNullOrEmpty
                        $Update.Version -match $Version | Should -Not -BeNullOrEmpty
                    }
                }
            }
        }

        Context "Validate list of Adobe Flash Player updates for Windows 8" {
            Write-Host ""
            Write-Host "`tBuilding variable for Windows 8." -ForegroundColor Cyan
            $Output = Get-LatestAdobeFlashUpdate -OperatingSystem Windows8

            It "Returns an array of 1 or more updates" {
                ($Output | Measure-Object).Count | Should -BeGreaterThan 0
            }
            It "Returns the expected output" {
                $Output | Should -BeOfType ((Get-Command Get-LatestAdobeFlashUpdate).OutputType.Type.Name)
            }
            ForEach ($Update in $Output) {
                It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.KB | Should -BeOfType System.String
                    $Update.Note | Should -BeOfType System.String
                    $Update.URL | Should -BeOfType System.String
                    $Update.Architecture | Should -BeOfType System.String
                    $Update.Version | Should -BeOfType System.String
                }
            }
        }
        Context "Returns expected results for Windows 8" {
            ForEach ($Update in $Output) {
                It "Returns updates for Windows $($Update.Version): [$($Update.Architecture)]" {
                    $Update.Note -match "$($ResourceStrings.SearchStrings.AdobeFlash).*$Version" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match $ResourceStrings.Architecture.All | Should -Not -BeNullOrEmpty
                    $Update.Version -match $Version | Should -Not -BeNullOrEmpty
                }
            }
        }
    }

    Describe 'Get-LatestAdobeFlashUpdate -Previous' {
        ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions) {
            Write-Host ""
            Write-Host "`tBuilding variable for Windows 10 [$Version] with -Previous." -ForegroundColor Cyan
            New-Variable -Name "Updates$Version" -Value (Get-LatestAdobeFlashUpdate -OperatingSystem Windows10 -Version $Version -Previous)
            $Output = (Get-Variable -Name "Updates$Version").Value
            Remove-Variable -Name "Updates$Version"

            Context "Validate list of Adobe Flash Player updates for Windows 10 $Version" {
                It "Returns an array of 1 or more updates" {
                    ($Output | Measure-Object).Count | Should -BeGreaterThan 0
                }
                ForEach ($Update in $Output) {
                    It "Returns an array with expected property types: [$($Update.Version), $($Update.Architecture)]" {
                        $Update.KB | Should -BeOfType System.String
                        $Update.Note | Should -BeOfType System.String
                        $Update.URL | Should -BeOfType System.String
                        $Update.Architecture | Should -BeOfType System.String
                        $Update.Version | Should -BeOfType System.String
                    }
                }
            }
        }
    }

    Describe 'Get-LatestWindowsDefenderUpdate' {
        Write-Host ""
        Write-Host "`tBuilding variable for Windows Defender." -ForegroundColor Cyan
        $DefenderUpdates = Get-LatestWindowsDefenderUpdate

        Context "Returns expected results with Windows Defender updates array" {
            ForEach ($Update in $DefenderUpdates) {
                It "Returns a Windows Defender update" {
                    $Update.Note -match $ResourceStrings.SearchStrings.WindowsDefender | Should -Not -BeNullOrEmpty
                }
            }
        }
        Context "Returns a valid Windows Defender update" {
            It "Returns an array of updates" {
                $DefenderUpdates | Should -BeOfType ((Get-Command Get-LatestWindowsDefenderUpdate).OutputType.Type.Name)
            }
            ForEach ($Update in $DefenderUpdates) {
                It "Given no arguments, Returns an array with expected property types" {
                    $Update.KB | Should -BeOfType System.String
                    $Update.Note | Should -BeOfType System.String
                    $Update.URL | Should -BeOfType System.String
                }
            }
        } 
    }

    Describe 'Save-LatestUpdate' {
    
        # Download target
        If (Test-Path -Path env:Temp) { $TempDir = $env:Temp }
        If (Test-Path -Path env:TMPDIR) { $TempDir = $env:TMPDIR }
        $Target = Join-Path -Path $TempDir -ChildPath ([System.IO.Path]::GetRandomFileName())
        New-Item -Path $Target -ItemType Directory -Force -ErrorAction SilentlyContinue

        Context "Downloads updates from Get-LatestWindowsDefenderUpdate" {
            $DefenderUpdates = Get-LatestWindowsDefenderUpdate
            $Downloads = Save-LatestUpdate -Updates $DefenderUpdates -Path $Target -ForceWebRequest
            ForEach ($Update in $DefenderUpdates) {
                ForEach ($File in $Update.Url) {
                    $Filename = Split-Path $File -Leaf
                    It "Given updates returned from Get-LatestWindowsDefenderUpdate, it successfully downloads the update." {
                        (Join-Path $Target $Filename) | Should -Exist
                    }
                }
            }
            ForEach ($Download in $Downloads) {
                It "Output from Save-LatestUpdate should have the expected properties" {
                    $Download.KB | Should -BeOfType System.String
                    $Download.Note | Should -BeOfType System.String
                    $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
                }
            }
        }

        # Skip download tests unless running in AppVeyor.
        If (Test-Path -Path 'env:APPVEYOR_BUILD_FOLDER') {

            # Get-LatestCumulativeUpdate
            ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions[0]) {
                Write-Host ""
                Write-Host "`tBuilding variable for Get-LatestCumulativeUpdate Windows 10 [$Version]." -ForegroundColor Cyan
                New-Variable -Name "Downloads$Version" -Value (Get-LatestCumulativeUpdate -OperatingSystem Windows10 -Version $Version)
                $Output = (Get-Variable -Name "Downloads$Version").Value
                Remove-Variable -Name "Downloads$Version"
    
                Context "Downloads updates from Get-LatestCumulativeUpdate for Windows 10 $Version" {
                    $Downloads = Save-LatestUpdate -Updates $Output -Path $Target -ForceWebRequest
                    ForEach ($Update in $Output) {
                        ForEach ($File in $Update.Url) {
                            $Filename = Split-Path $File -Leaf
                            It "Given updates returned from Get-LatestCumulativeUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]." {
                                (Join-Path $Target $Filename) | Should -Exist
                            }
                        }
                    }
                    ForEach ($Download in $Downloads) {
                        It "Output from Save-LatestUpdate should have the expected properties" {
                            $Download.KB | Should -BeOfType System.String
                            $Download.Note | Should -BeOfType System.String
                            $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
                        }
                    }
                }
            }

            # Get-LatestServicingStack
            ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions[0]) {
                Write-Host ""
                Write-Host "`tBuilding variable for Get-LatestServicingStack Windows 10 [$Version]." -ForegroundColor Cyan
                New-Variable -Name "Downloads$Version" -Value (Get-LatestServicingStack -OperatingSystem Windows10 -Version $Version)
                $Output = (Get-Variable -Name "Downloads$Version").Value
                Remove-Variable -Name "Downloads$Version"

                Context "Downloads updates from Get-LatestServicingStack for Windows 10 $Version" {
                    $Downloads = Save-LatestUpdate -Updates $Output -Path $Target -ForceWebRequest
                    ForEach ($Update in $Output) {
                        ForEach ($File in $Update.Url) {
                            $Filename = Split-Path $File -Leaf
                            It "Given updates returned from Get-LatestServicingStack, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]." {
                                (Join-Path $Target $Filename) | Should -Exist
                            }
                        }
                    }
                    ForEach ($Download in $Downloads) {
                        It "Output from Save-LatestUpdate should have the expected properties" {
                            $Download.KB | Should -BeOfType System.String
                            $Download.Note | Should -BeOfType System.String
                            $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
                        }
                    }
                }
            }

            # Get-LatestNetFrameworkUpdate
            ForEach ($Version in $ResourceStrings.ParameterValues.VersionsComplete[0]) {
                Write-Host ""
                Write-Host "`tBuilding variable for Get-LatestNetFrameworkUpdate [$Version]." -ForegroundColor Cyan
                New-Variable -Name "Downloads$Version" -Value (Get-LatestNetFrameworkUpdate -OperatingSystem $Version)
                $Output = (Get-Variable -Name "Downloads$Version").Value
                Remove-Variable -Name "Downloads$Version"

                Context "Downloads updates from Get-LatestNetFrameworkUpdate for Windows $Version" {
                    $Downloads = Save-LatestUpdate -Updates $Output -Path $Target -ForceWebRequest
                    ForEach ($Update in $Output) {
                        ForEach ($File in $Update.Url) {
                            $Filename = Split-Path $File -Leaf
                            It "Given updates returned from Get-LatestNetFrameworkUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]." {
                                (Join-Path $Target $Filename) | Should -Exist
                            }
                        }
                    }
                    ForEach ($Download in $Downloads) {
                        It "Output from Save-LatestUpdate should have the expected properties" {
                            $Download.KB | Should -BeOfType System.String
                            $Download.Note | Should -BeOfType System.String
                            $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
                        }
                    }
                }
            }

            # Get-LatestAdobeFlashUpdate Windows 10
            ForEach ($Version in $ResourceStrings.ParameterValues.Windows10Versions[0]) {
                Write-Host ""
                Write-Host "`tBuilding variable for Get-LatestAdobeFlashUpdate Windows 10 [$Version]." -ForegroundColor Cyan
                New-Variable -Name "Downloads$Version" -Value (Get-LatestAdobeFlashUpdate -OperatingSystem Windows10 -Version $Version)
                $Output = (Get-Variable -Name "Downloads$Version").Value
                Remove-Variable -Name "Downloads$Version"
        
                Context "Downloads updates from Get-LatestAdobeFlashUpdate for Windows 10 $Version" {
                    $Downloads = Save-LatestUpdate -Updates $Output -Path $Target -ForceWebRequest
                    ForEach ($Update in $Output) {
                        ForEach ($File in $Update.Url) {
                            $Filename = Split-Path $File -Leaf
                            It "Given updates returned from Get-LatestAdobeFlashUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]." {
                                (Join-Path $Target $Filename) | Should -Exist
                            }
                        }
                    }
                    ForEach ($Download in $Downloads) {
                        It "Output from Save-LatestUpdate should have the expected properties" {
                            $Download.KB | Should -BeOfType System.String
                            $Download.Note | Should -BeOfType System.String
                            $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
                        }
                    }
                }
            }

            # Get-LatestAdobeFlashUpdate Windows 8
            Write-Host ""
            Write-Host "`tBuilding variable for Get-LatestAdobeFlashUpdate Windows 8." -ForegroundColor Cyan
            $Output = Get-LatestAdobeFlashUpdate -OperatingSystem Windows8
            Context "Downloads updates from Get-LatestAdobeFlashUpdate for Windows 8" {
                $Downloads = Save-LatestUpdate -Updates $Output -Path $Target -ForceWebRequest
                ForEach ($Update in $Output) {
                    ForEach ($File in $Update.Url) {
                        $Filename = Split-Path $File -Leaf
                        It "Given updates returned from Get-LatestAdobeFlashUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]." {
                            (Join-Path $Target $Filename) | Should -Exist
                        }
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB | Should -BeOfType System.String
                        $Download.Note | Should -BeOfType System.String
                        $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
                    }
                }
            }

            # Get-LatestMonthlyRollup
            ForEach ($Version in $ResourceStrings.ParameterValues.Versions87[0]) {
                Write-Host ""
                Write-Host "`tBuilding variable for Get-LatestMonthlyRollup [$Version]." -ForegroundColor Cyan
                New-Variable -Name "Downloads$Version" -Value (Get-LatestMonthlyRollup -OperatingSystem $Version)
                $Output = (Get-Variable -Name "Downloads$Version").Value
                Remove-Variable -Name "Downloads$Version"
        
                Context "Downloads updates from Get-LatestMonthlyRollup for $Version" {
                    $Downloads = Save-LatestUpdate -Updates $Output -Path $Target -ForceWebRequest
                    ForEach ($Update in $Output) {
                        ForEach ($File in $Update.Url) {
                            $Filename = Split-Path $File -Leaf
                            It "Given updates returned from Get-LatestMonthlyRollup, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]." {
                                (Join-Path $Target $Filename) | Should -Exist
                            }
                        }
                    }
                    ForEach ($Download in $Downloads) {
                        It "Output from Save-LatestUpdate should have the expected properties" {
                            $Download.KB | Should -BeOfType System.String
                            $Download.Note | Should -BeOfType System.String
                            $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
                        }
                    }
                }
            }

        }

        # Calculate downloaded size
        $Size = "{0:N2} MB" -f ((Get-ChildItem $Target -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
        Write-Host ""
        Write-Host "Total download size: $Size." -ForegroundColor Cyan
        Remove-Item -Path $Target -Recurse -Force
    }
}

<# - Currently failing on AppVeyor
Context "Download via BITS Transfer" {
    Disable-NetFirewallRule -DisplayName 'Core Networking - Group Policy (TCP-Out)'
    $DownloadPath = Join-Path -Path $Target -ChildPath ([System.IO.Path]::GetRandomFileName())
    New-Item -Path $DownloadPath -ItemType Directory -Force
    Save-LatestUpdate -Updates $StackUpdates -Path $DownloadPath
    ForEach ($Update in $StackUpdates) {
        $Filename = Split-Path $Update.Url -Leaf
        It "Given downloads via BITS, it successfully downloads the update" {
            (Join-Path $DownloadPath $Filename) | Should -Exist
        }
    }
    ForEach ($Download in $Downloads) {
        It "Output from Save-LatestUpdate should have the expected properties" {
            $Download.KB | Should -BeOfType System.String
            $Download.Note | Should -BeOfType System.String
            $Download.Path | Should -BeOfType System.Management.Automation.PathInfo
        }
    }
}
#>
