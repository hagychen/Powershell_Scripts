# C:\scripts\notify_start.ps1
# Notify Telegram on boot

# --- CONFIG: điền token & chat id ở đây ---
$botToken = "8206919621:AAFcinqPKc6c7mdrWfkzRO_AFmkbTK23Fis"
$chatId   = "5962830334"
# -----------------------------------------

# Info
$pcName = $env:COMPUTERNAME
$user   = $env:USERNAME

# Lấy IP local (loại trừ APIPA và loopback)
try {
    $ipobj = Get-NetIPAddress -AddressFamily IPv4 |
            Where-Object { $_.IPAddress -notlike "169.*" -and $_.IPAddress -ne "127.0.0.1" } |
            Select-Object -First 1
    $ip = if ($ipobj) { $ipobj.IPAddress } else { "No IP (maybe network not ready)" }
} catch {
    $ip = "Unknown"
}

# Optionally lấy public IP (yêu cầu internet). Không bắt buộc.
try {
    $publicIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=text" -TimeoutSec 5) -as [string]
} catch {
    $publicIp = "Unavailable"
}

$time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$msg = " >>*My PC Power On With*<<`n`Host`: *$pcName*`n`User`: *$user*`n`Time`: $time`n`Local IP`: $ip`n`Public IP`: $publicIp"

$payload = @{
    chat_id = $chatId
    text    = $msg
    parse_mode = "Markdown"
}

# Gửi (với retry cơ bản)
$maxTries = 3
for ($i=1; $i -le $maxTries; $i++) {
    try {
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/sendMessage" -Method Post -Body $payload -TimeoutSec 10
        break
    } catch {
        Start-Sleep -Seconds (2 * $i)
        if ($i -eq $maxTries) {
            # Log lỗi nếu thất bại
            $err = "$(Get-Date -Format 's') - Failed to send Telegram message. Error: $($_.Exception.Message)"
            $err | Out-File -FilePath "C:\scripts\notify_error.log" -Append -Encoding utf8
        }
    }
}
