$encryptedApiKey = Get-Content -Path 'c:\pathToEncryptFiles\api_key.txt' | ConvertTo-SecureString
$encryptedApiSecret = Get-Content -Path 'c:\pathToEncryptFiles\api_secret.txt' | ConvertTo-SecureString

$apiKeyPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedApiKey))
$apiSecretPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedApiSecret))


$DomainName = 'domain.com'
$recType = 'A'
$subdomain = 'sub'
$extIP = (Invoke-WebRequest ifconfig.me/ip).Content

$bodyObject = @{
        apikey = $apiKeyPlainText
        secretapikey = $apiSecretPlainText
    }

$APIResult = Invoke-WebRequest -Uri "https://porkbun.com/api/json/v3/dns/retrieveByNameType/$DomainName/$recType/$subdomain" `
                -Body ($bodyObject | ConvertTo-Json) `
                -Method Post
$response = $APIResult.Content | ConvertFrom-Json
$dnsip = $response.records.content

if([ipaddress]$dnsip -and $dnsip -ne $extIP) {
    $bodyObject += @{ content = $extIP }

     $APIResult = Invoke-WebRequest "https://porkbun.com/api/json/v3/dns/editByNameType/$DomainName/$recType/$subdomain" `
                    -Method Post `
                    -Body $bodyObject | ConvertTo-Json
} else { "No Changes" }
