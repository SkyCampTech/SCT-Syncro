Import-Module $env:SyncroModule

$chromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
switch ($ChromeNotificationType) {
    "AllowSites" { $value = 1 }
    "BlockSites" { $value = 2 }
    "SiteAsks" { $value = 3 }
    Default { $value = 3 }
}
New-ItemProperty -Path $chromePath -Name "DefaultNotificationsSetting" -PropertyType DWord -Value $value -Force