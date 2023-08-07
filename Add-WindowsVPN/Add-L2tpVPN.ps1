Import-Module $env:SyncroModule

#adapted CyberDrain's script: https://admin.syncromsp.com/shared_scripts/1327

$settings = @{
    Name                  = $vpnName
    AllUserConnection     = [boolean]$allUsersConnection
    ServerAddress         = $vpnAddress
    TunnelType            = "L2TP"
    SplitTunneling        = [boolean]$splitTunnel
    UseWinLogonCredential = [boolean]$useWinLogonCreds
    L2tpPsk               = $L2tpPsk
    AuthenticationMethod  = $authMethod
}

$VPN = Get-VpnConnection -Name $($Settings.Name) -AllUserConnection -ErrorAction SilentlyContinue

if (!$VPN) {
    Add-VpnConnection @Settings -Verbose -Force
}
else {
    Set-VpnConnection @settings -Verbose -Force
}