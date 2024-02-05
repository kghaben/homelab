$encryptedApiKey = Get-Content -Path 'c:\pathToEncryptFiles\api_key.txt' | ConvertTo-SecureString
$encryptedApiSecret = Get-Content -Path 'c:\pathToEncryptFiles\api_secret.txt' | ConvertTo-SecureString

$apiKeyPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedApiKey))
$apiSecretPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedApiSecret))


$DomainName = 'domain.com'
$recType = 'A'
$subdomain = 'subdomain'
$certPath = ""


$bodyObject = @{
        apikey = $apiKeyPlainText
        secretapikey = $apiSecretPlainText
    }

$APIResult = Invoke-WebRequest -Uri "https://porkbun.com/api/json/v3/ssl/retrieve/$DomainName/$recType/$subdomain" `
                -Body ($bodyObject | ConvertTo-Json) `
                -Method Post
$response = $APIResult.Content | ConvertFrom-Json
$response.privatekey | Out-File $certPath\cs.priv_key -Encoding ascii
$response.intermediatecertificate | Out-File $certPath\cs.ca_bundle -Encoding ascii
$response.certificatechain | Out-File $certPath\cs.cert -Encoding ascii

