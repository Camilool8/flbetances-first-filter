[CmdletBinding()]
param()

# See http://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx for details on how to detect framework versions
# Also see http://support.microsoft.com/kb/318785

function Add-Versions {
    [CmdletBinding()]
    param(
        [string]$NameFormat,

        [Parameter(Mandatory = $true)]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [ref]$LatestValue)

    # Get the install root from the registry.
    $installRoot = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName 'Software\Microsoft\.NETFramework' -ValueName 'InstallRoot'
    if (!$installRoot) {
        return
    }

    # Get the version sub key names.
    $ndpKeyName = 'Software\Microsoft\NET Framework Setup\NDP'
    $versionSubKeyNames =
        Get-RegistrySubKeyNames -Hive 'LocalMachine' -View $View -KeyName $ndpKeyName |
        Where-Object { $_ -like 'v*' }
    foreach ($versionSubKeyName in $versionSubKeyNames) {
        # Get the version.
        $versionKeyName = "$ndpKeyName\$versionSubKeyName"
        $version = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName 'Version'
        if ($version) {
            # Check if installed.
            $install = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName 'Install'
            if ($install -ne 1) {
                continue
            }

            # Verify the expected install path.
            $version
            $installPath = [System.IO.Path]::Combine($installRoot, $versionSubKeyName)
            if (!(Test-Container -LiteralPath $installPath)) {
                continue
            }

            # Parse the version from the sub key name.
            $versionObject = [System.Version]::Parse($versionSubKeyName.Substring(1))
            $capabilityName = ($NameFormat -f "$($versionObject.Major).$($versionObject.Minor)")

            # Add the capability.
            Write-Capability -Name $capabilityName -Value $installPath
            $LatestValue.Value = $installPath
            continue
        }

        # Check if deprecated.
        $default = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName ''
        if ($default -eq 'deprecated') {
            continue
        }

        # Get the profile key names.
        $profileKeyNames =
            Get-RegistrySubKeyNames -Hive 'LocalMachine' -View $View -KeyName $versionKeyName |
            ForEach-Object { "$versionKeyName\$_" }
        foreach ($profileKeyName in $profileKeyNames) {
            # Skip if version not found.
            $version = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Version'
            if (!$version) {
                continue
            }

            # Skip if not installed.
            $install = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Install'
            if ($install -ne 1) {
                continue
            }

            # Skip if install path value not found.
            $installPath = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'InstallPath'
            $installPath = "$installPath".TrimEnd([System.IO.Path]::DirectorySeparatorChar)
            if (!$installPath) {
                continue
            }

            # Determine the version string.
            $release = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Release'
            $versionString = switch ($release) {
                # We put the releaseVersion into version range, since customer might install beta/preview version .NET Framework.
                # These magic values come from: https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
                378389 { "4.5.0" }
                { $_ -gt 378389 -and $_ -le 378758 } { "4.5.1" }
                { $_ -gt 378758 -and $_ -le 379893 } { "4.5.2" }
                { $_ -gt 379893 -and $_ -le 380995 } { "4.5.3" }
                { $_ -gt 380995 -and $_ -le 393297 } { "4.6.0" }
                { $_ -gt 393297 -and $_ -le 394271 } { "4.6.1" }
                { $_ -gt 394271 -and $_ -le 394806 } { "4.6.2" }
                { $_ -gt 394806 -and $_ -le 460805 } { "4.7.0" }
                { $_ -gt 460805 -and $_ -le 461310 } { "4.7.1" }
                { $_ -gt 461310 -and $_ -le 461814 } { "4.7.2" }
                { $_ -gt 461814 } { "4.8.0"}
            }

            if (!$versionString) {
                continue
            }

            Write-Capability -Name ($NameFormat -f $versionString) -Value $installPath
            $LatestValue.Value = $installPath
        }
    }
}

$latest = $null
Add-Versions -NameFormat 'DotNetFramework_{0}' -View 'Registry32' -LatestValue ([ref]$latest)
Add-Versions -NameFormat 'DotNetFramework_{0}_x64' -View 'Registry64' -LatestValue ([ref]$latest)
if ($latest) {
    Write-Capability -Name 'DotNetFramework' -Value $latest
}

# SIG # Begin signature block
# MIIoPAYJKoZIhvcNAQcCoIIoLTCCKCkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC0aaovVM6v0u2o
# XGzrZZhCY6U1OHc037uwZhTto6AUmKCCDYUwggYDMIID66ADAgECAhMzAAADri01
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIGls
# cItQe4dbGbFjDJcHXKEzijT3xBBsb/V8KoQJjkCYMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAMIu43jDCiyXJkyZjs9iFPRIdSANq9pDUzC6W
# eWmBr6kym5wgvEM0o8e/TRgGsjjcvm7MYAqcSxh5Q7++9/Cy6BDOIngr4w+jo1Pw
# NbJMj87juYRlHkDVhx5aJPGcEIplYZuuptGoX6MYB9cwRhk0tAWWkk93I857Y5Dg
# nAJIGzIzADYmVFDuv9bfQlhhOOqgEzLoKqpHfCDTSuCPD4h+uOMihxTkz3sw35IY
# jExGwa8QoEUbxdGCob3ciYX0GwFoxhkRclyHKDs/ffM04LX2Aj2S1s937UpNIFbh
# YGUwx6Lcyn1IoJH7XiZuXTlFb+6kfmltLInFtZeuCbggiwk8q6GCF5cwgheTBgor
# BgEEAYI3AwMBMYIXgzCCF38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCA2G7JOzcqgz+QI/9ln/QbgUx+ud+dkitqB
# /+qxgUNN2gIGZhgOMaTsGBMyMDI0MDUwMTA5MjI0NS4wMDZaMASAAgH0oIHRpIHO
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
# MQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCD9/QNW5rWK2D7ey+ma9+UN
# N+RmWEM/O3avPwWMdr36QTCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EICmP
# odXjZDR4iwg0ltLANXBh5G1uKqKIvq8sjKekuGZ4MIGYMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHqmiRy1Vk/YWMAAQAAAeowIgQguEFh
# YASkRGl06iPl6vyiT8BRyItwC+E59uR/WOk7keswDQYJKoZIhvcNAQELBQAEggIA
# QQ8TlScCOjoRxA7RbYGImqWSZVfqF5Ej7KTFZhdzztx3hyG3RuB34DXyZstcfw9g
# UwPHCEsA6sVSYhFHiJKmwI9z4T83vQLN4aHpV4aXe2fpUS52fRsfpGtbMiILnbJ+
# GtnmAF94pDuMRqh1puBjF0ABcr2DkyfYcNKUvaQjXCyzVWPGehQjKSlW4kHQv+3C
# b97BR/jxln0NxXaEX6uzp4dIE+uT0X1Zk8OgZGf6ZBedOaND33wQPdn3o/oiLa/7
# YDqug6X2wPBNwFbkO/WByugAkstrISVlrUm2dVwkTCsZz6Y6B4rrohuAenbpfIGQ
# Ce8Af0szE/+Q1GmOuoqh72odbcLTiyn21mKG99ZrkgqhtFi6kGeBMeyna0YzFHgT
# jqRa1oNbRaZrRvyeyrXTIiD55VDGNtV6BQRSI3CuUQsuMlX6Eg4OChW3mQFN8UtK
# OaWvwHiUYvF0zmOJcImeh6jbg5FJBnkTjIadiJ1YcLjr4RBErrnL4kW+7dx2IoX8
# D7+NZvCIhQ9visrKt07euk55NoSyl9OF/AZ9DKg54ckKI7VygeVuU02L1gc8iZGN
# ICklXth/oBRE4nra5uSO4MrPgePxyS+5Gim5uQPo0fh5DBwSVnQyFQuNTfcCmxkW
# LrsgwhwOad0YkQdcjIGX3p31e31hR+TcNmB2hrJ4+Zw=
# SIG # End signature block
