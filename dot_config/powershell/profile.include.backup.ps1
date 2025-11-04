# If on windows copy shell history to the E drive
$backupPath = "E:\Settings"
if (Test-Path $backupPath)
{
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath)
    {
        Copy-Item -Path $historyPath -Destination ( Join-Path $backupPath "powershell-history.txt" )
    }
}