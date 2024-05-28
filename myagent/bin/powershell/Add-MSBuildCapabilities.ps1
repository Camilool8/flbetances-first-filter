[CmdletBinding()]
param()

function Get-MSBuildCapabilities {
    param (
        [Parameter(Mandatory = $true)]
        [int]$MajorVersion,

        [switch]$Add_x64
    )

    $vs = Get-VisualStudio -MajorVersion $MajorVersion
    
    $capabilitySuffix = [string]::Empty
    if($Add_x64)
    {
        $msbuildInstallationPath = 'MSBuild\Current\Bin\amd64'
        $capabilitySuffix = "_x64"
    }
    else
    {
        $msbuildInstallationPath = 'MSBuild\Current\Bin'
    }

    if ($vs -and $vs.installationPath) {
        # Add MSBuild_$($MajorVersion).0.
        # End with "\" for consistency with old MSBuildToolsPath value.
        $msbuild = ([System.IO.Path]::Combine($vs.installationPath, $msbuildInstallationPath)) + '\'
        if ((Test-Leaf -LiteralPath "$($msbuild)MSBuild.exe")) {
            Write-Capability -Name "MSBuild_$($MajorVersion).0$($capabilitySuffix)" -Value $msbuild
            $latest = $msbuild
        }
    }
    if ($latest) {
        Write-Capability -Name "MSBuild$($capabilitySuffix)" -Value $latest
    }
}

# Define the key names.
$keyName20 = "Software\Microsoft\MSBuild\ToolsVersions\2.0"
$keyName35 = "Software\Microsoft\MSBuild\ToolsVersions\3.5"
$keyName40 = "Software\Microsoft\MSBuild\ToolsVersions\4.0"
$keyName12 = "Software\Microsoft\MSBuild\ToolsVersions\12.0"
$keyName14 = "Software\Microsoft\MSBuild\ToolsVersions\14.0"

# Add 32-bit.
$latest = $null
$null = Add-CapabilityFromRegistry -Name "MSBuild_2.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName20 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_3.5" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName35 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_4.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName40 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_12.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName12 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_14.0" -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName14 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$vs15 = Get-VisualStudio -MajorVersion 15
if ($vs15 -and $vs15.installationPath) {
    # Add MSBuild_15.0.
    # End with "\" for consistency with old MSBuildToolsPath value.
    $msbuild15 = ([System.IO.Path]::Combine($vs15.installationPath, 'MSBuild\15.0\Bin')) + '\'
    if ((Test-Leaf -LiteralPath "$($msbuild15)MSBuild.exe")) {
        Write-Capability -Name 'MSBuild_15.0' -Value $msbuild15
        $latest = $msbuild15
    }
}

Get-MSBuildCapabilities -MajorVersion 16

Get-MSBuildCapabilities -MajorVersion 17

# Add 64-bit.
$latest = $null
$null = Add-CapabilityFromRegistry -Name "MSBuild_2.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName20 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_3.5_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName35 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_4.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName40 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_12.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName12 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
$null = Add-CapabilityFromRegistry -Name "MSBuild_14.0_x64" -Hive 'LocalMachine' -View 'Registry64' -KeyName $keyName14 -ValueName 'MSBuildToolsPath' -Value ([ref]$latest)
if ($vs15 -and $vs15.installationPath) {
    # Add MSBuild_15.0_x64.
    # End with "\" for consistency with old MSBuildToolsPath value.
    $msbuild15 = ([System.IO.Path]::Combine($vs15.installationPath, 'MSBuild\15.0\Bin\amd64')) + '\'
    if ((Test-Leaf -LiteralPath "$($msbuild15)MSBuild.exe")) {
        Write-Capability -Name 'MSBuild_15.0_x64' -Value $msbuild15
        $latest = $msbuild15
    }
}

Get-MSBuildCapabilities -MajorVersion 16 -Add_x64

Get-MSBuildCapabilities -MajorVersion 17 -Add_x64

# SIG # Begin signature block
# MIIoPAYJKoZIhvcNAQcCoIIoLTCCKCkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCERQsWCn/wZ7Rg
# 0a2g3mqXfwAY6KOuNQVPte9+XZTS+KCCDYUwggYDMIID66ADAgECAhMzAAADri01
# UchTj1UdAAAAAAOuMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwODU5WhcNMjQxMTE0MTkwODU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQD0IPymNjfDEKg+YyE6SjDvJwKW1+pieqTjAY0CnOHZ1Nj5irGjNZPMlQ4HfxXG
# yAVCZcEWE4x2sZgam872R1s0+TAelOtbqFmoW4suJHAYoTHhkznNVKpscm5fZ899
# QnReZv5WtWwbD8HAFXbPPStW2JKCqPcZ54Y6wbuWV9bKtKPImqbkMcTejTgEAj82
# 6GQc6/Th66Koka8cUIvz59e/IP04DGrh9wkq2jIFvQ8EDegw1B4KyJTIs76+hmpV
# M5SwBZjRs3liOQrierkNVo11WuujB3kBf2CbPoP9MlOyyezqkMIbTRj4OHeKlamd
# WaSFhwHLJRIQpfc8sLwOSIBBAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhx/vdKmXhwc4WiWXbsf0I53h8T8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMTgzNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGrJYDUS7s8o0yNprGXRXuAnRcHKxSjFmW4wclcUTYsQZkhnbMwthWM6cAYb/h2W
# 5GNKtlmj/y/CThe3y/o0EH2h+jwfU/9eJ0fK1ZO/2WD0xi777qU+a7l8KjMPdwjY
# 0tk9bYEGEZfYPRHy1AGPQVuZlG4i5ymJDsMrcIcqV8pxzsw/yk/O4y/nlOjHz4oV
# APU0br5t9tgD8E08GSDi3I6H57Ftod9w26h0MlQiOr10Xqhr5iPLS7SlQwj8HW37
# ybqsmjQpKhmWul6xiXSNGGm36GarHy4Q1egYlxhlUnk3ZKSr3QtWIo1GGL03hT57
# xzjL25fKiZQX/q+II8nuG5M0Qmjvl6Egltr4hZ3e3FQRzRHfLoNPq3ELpxbWdH8t
# Nuj0j/x9Crnfwbki8n57mJKI5JVWRWTSLmbTcDDLkTZlJLg9V1BIJwXGY3i2kR9i
# 5HsADL8YlW0gMWVSlKB1eiSlK6LmFi0rVH16dde+j5T/EaQtFz6qngN7d1lvO7uk
# 6rtX+MLKG4LDRsQgBTi6sIYiKntMjoYFHMPvI/OMUip5ljtLitVbkFGfagSqmbxK
# 7rJMhC8wiTzHanBg1Rrbff1niBbnFbbV4UDmYumjs1FIpFCazk6AADXxoKCo5TsO
# zSHqr9gHgGYQC2hMyX9MGLIpowYCURx3L7kUiGbOiMwaMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAOuLTVRyFOPVR0AAAAA
# A64wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEICJH
# vFN4W9RbPdSCMRDrtRnjAO6JHM+vIJngjPUDk0N+MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAK54pTgli1Z6EBRXKmwHXhoQ9qtev7hmYdTeg
# G8jOYqfBT6khmw8Uh1QCyPGD9cHmmmGTIS4QyisRDGAMYzUbKO4ugSqPtHZIZTzd
# ZoyTwK+e1AGDc5klwoabXPFnD8uj1+ubEOXcvZcGGMiCd3axGzKwMorRndO7fVqy
# iwV7T7o3e29zVU1mhu1WhNPpY+VUpErjP8UFidukbNOpI+g9LJCu8q2QBtVAMPLy
# YE5Moue0m+35GFaVS5NmfsRfaKqxtzvLAOmNmu6aCosuM8yX7DBxNrx0bhUejJCW
# iSSJ1qAtYRjxhdiU+d962smoISGfrm2gipw6bSeSDDjb+r+aoKGCF5cwgheTBgor
# BgEEAYI3AwMBMYIXgzCCF38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCBC7SCNd7pUZOew2zoktC8RxSEAnkAZ5WWY
# nbgS6791QAIGZhgOMaSdGBMyMDI0MDUwMTA5MjI0My44NThaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046MzcwMy0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHtMIIHIDCCBQigAwIBAgITMwAAAeqaJHLVWT9hYwAB
# AAAB6jANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDAeFw0yMzEyMDYxODQ1MzBaFw0yNTAzMDUxODQ1MzBaMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzcwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC1C1/xSD8gB9X7Ludoo2rW
# b2ksqaF65QtJkbQpmsc6G4bg5MOv6WP/uJ4XOJvKX/c1t0ej4oWBqdGD6VbjXX4T
# 0KfylTulrzKtgxnxZh7q1uD0Dy/w5G0DJDPb6oxQrz6vMV2Z3y9ZxjfZqBnDfqGo
# n/4VDHnZhdas22svSC5GHywsQ2J90MM7L4ecY8TnLI85kXXTVESb09txL2tHMYrB
# +KHCy08ds36an7IcOGfRmhHbFoPa5om9YGpVKS8xeT7EAwW7WbXL/lo5p9KRRIjA
# lsBBHD1TdGBucrGC3TQXSTp9s7DjkvvNFuUa0BKsz6UiCLxJGQSZhd2iOJTEfJ1f
# xYk2nY6SCKsV+VmtV5aiPzY/sWoFY542+zzrAPr4elrvr9uB6ci/Kci//EOERZEU
# TBPXME/ia+t8jrT2y3ug15MSCVuhOsNrmuZFwaRCrRED0yz4V9wlMTGHIJW55iNM
# 3HPVJJ19vOSvrCP9lsEcEwWZIQ1FCyPOnkM1fs7880dahAa5UmPqMk5WEKxzDPVp
# 081X5RQ6HGVUz6ZdgQ0jcT59EG+CKDPRD6mx8ovzIpS/r/wEHPKt5kOhYrjyQHXc
# 9KHKTWfXpAVj1Syqt5X4nr+Mpeubv+N/PjQEPr0iYJDjSzJrqILhBs5pytb6vyR8
# HUVMp+mAA4rXjOw42vkHfQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFCuBRSWiUebp
# F0BU1MTIcosFblleMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQAog61WXj9+/nxV
# bX3G37KgvyoNAnuu2w3HoWZj3H0YCeQ3b9KSZThVThW4iFcHrKnhFMBbXJX4uQI5
# 3kOWSaWCaV3xCznpRt3c4/gSn3dvO/1GP3MJkpJfgo56CgS9zLOiP31kfmpUdPqe
# kZb4ivMR6LoPb5HNlq0WbBpzFbtsTjNrTyfqqcqAwc6r99Df2UQTqDa0vzwpA8Cx
# iAg2KlbPyMwBOPcr9hJT8sGpX/ZhLDh11dZcbUAzXHo1RJorSSftVa9hLWnzxGzE
# GafPUwLmoETihOGLqIQlCpvr94Hiak0Gq0wY6lduUQjk/lxZ4EzAw/cGMek8J3Qd
# iNS8u9ujYh1B7NLr6t3IglfScDV3bdVWet1itTUoKVRLIivRDwAT7dRH13Cq32j2
# JG5BYu/XitRE8cdzaJmDVBzYhlPl9QXvC+6qR8I6NIN/9914bTq/S4g6FF4f1dix
# UxE4qlfUPMixGr0Ft4/S0P4fwmhs+WHRn62PB4j3zCHixKJCsRn9IR3ExBQKQdMi
# 5auiqB6xQBADUf+F7hSKZfbA8sFSFreLSqhvj+qUQF84NcxuaxpbJWVpsO18IL4Q
# bt45Cz/QMa7EmMGNn7a8MM3uTQOlQy0u6c/jq111i1JqMjayTceQZNMBMM5EMc5D
# r5m3T4bDj9WTNLgP8SFe3EqTaWVMOTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
# SZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIy
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
# yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjo
# YH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1y
# aa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v
# 3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pG
# ve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
# kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYr
# bqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlM
# jgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
# W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
# emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIu
# rQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
# FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEW
# M2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5
# Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
# AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
# 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
# LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv
# 6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
# OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1
# bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4
# rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU
# 6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDF
# NLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
# HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdU
# CbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKi
# excdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
# dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
# ELQdVTNYs6FwZvKhggNQMIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjM3MDMtMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQCJ2x7cQfjpRskJ8UGIctOCkmEkj6CBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6dxA1DAi
# GA8yMDI0MDUwMTA0MTcyNFoYDzIwMjQwNTAyMDQxNzI0WjB3MD0GCisGAQQBhFkK
# BAExLzAtMAoCBQDp3EDUAgEAMAoCAQACAhneAgH/MAcCAQACAhN7MAoCBQDp3ZJU
# AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSCh
# CjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAEvOHfezPe0Cfm89gKQkwAbg
# XEzIDfv8CsezhbzGDgVZtObjA4rJCAydHmCn3fv+xw1fqSRvqj8tilMQfK+puX4e
# R7L0y860S/d6Ps4yuZ6chI1yBqU5kPAZacHHN93sktfGU4AacI+yfx2t5+AAgBQr
# 3ZAlKXZn5QFeYz9LYL6cNWOARRWjisgh6iqGExBpt6sr4F5gbvZXImmOq6LRDt+y
# k2upmplXRFUW4PWcrHtd92mOZUJNw4DRn8JCTogJQ4yfTAX3E9CyxSIhN+gcexGl
# XQCGHrL8N6d784HKTh+4kv+5eU8jrerdVplvxcwp/TugfP3cRA7QwKX4Q3qja3cx
# ggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAA
# AeqaJHLVWT9hYwABAAAB6jANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkD
# MQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAYqxp21iE16y5TSr6sJheZ
# pS/m/zNLBHLCg7Mc7JsTdjCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EICmP
# odXjZDR4iwg0ltLANXBh5G1uKqKIvq8sjKekuGZ4MIGYMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHqmiRy1Vk/YWMAAQAAAeowIgQguEFh
# YASkRGl06iPl6vyiT8BRyItwC+E59uR/WOk7keswDQYJKoZIhvcNAQELBQAEggIA
# WrHy5/P1t3Ho/PgDxjozvjjwhiWolEYjYHjDQ2wsQ6Y2zDy/xd8EM+8qQT7ah+9b
# nFjqdeIrLjDLPp06DUlS10maiHYowIjyVgAgQYhymBPcioJ00XLIUbhurdHzEnp3
# h52sfJd+GchLOSaUIQcCY4Qg2PxiPNpTmRvn8F7Djq+LNCQRq79djmXblDz/VPYi
# GTyMNnM3+6yjZ7QkJUvahXjmwcsaFHHe0ZPbsa/kDoDRcrFDGRPgUtapqTcmJN6+
# +sUkkTQ8yy3vFY8XQwrBu32sNvPr4+Ob6sO1CoTAGkI7+h1d9x4Ccsnyr6oNLDWe
# R+meipbAeoAbL2J1CivCJ5bgCA+rXKJZSmU3TXfQUj0YGTxhSe/CH/uNAE5HegyV
# nmDvSIZ8zFuexL9/llW+FyEY5oIKP0MD/UCYE786qjGwZ6PaqYy+lFd+t7/37WzP
# NOSgmGt6dnuNccVORwB6ndPE95yEbj1+eyWSDpFJc8vScBYY1vuirLXRIYwz3zgx
# gO9yvzDT28nxvS24xOd909LdP0DPBCygQ1STt2pdTVp9WcoMw1gWg984gIrqhLvA
# wlTe/8mbZpz72rgPCILB0gnSIaW8Wz40HpapUW1gvcv3XLXsn8zMSYReKn9BwRNK
# WuDw8qFSBA4UN39Jw/628lM+ra6woIu/ZPYa1514usE=
# SIG # End signature block
