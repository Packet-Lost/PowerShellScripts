function Get-AsciiShrug {
    $OutputEncoding = [System.Text.Encoding]::unicode
    write-output "�\_($(0x30C4|%{[char]$_}))_/�" | clip
}