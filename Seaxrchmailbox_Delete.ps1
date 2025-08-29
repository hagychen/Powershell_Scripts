Get-MailboxDatabase | Get-MailboxStatistics | Where { $_.DisconnectReason -eq "Disabled" -and $_.DisplayName -like "*ERP*" } | FT DisplayName, MailboxGuid, Database, DisconnectDate

