# Unpin taskbar items
function Unpin {
    param ([string]$appname)
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() |
    Where-Object { $_.Name -eq $appname }).Verbs() |
    Where-Object { $_.Name.replace('&', '') -match 'Unpin from taskbar' } |
    ForEach-Object { $_.DoIt() }
}
if ($Amazon) {
    Unpin "Amazon"
}
if ($HpJumpStart) {
    Unpin "HP JumpStart"
}
if ($HpSupport) {
    Unpin "HP Support Assistant"
}
if ($Mail) {
    Unpin "Mail"
}
if ($MSStore) {
    Unpin "Microsoft Store"
}