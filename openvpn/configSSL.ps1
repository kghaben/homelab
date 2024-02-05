#copy and configures SSL certs on OpenVPN appliance or linux-based OS
$openvpnIP = ""
$openvpnCertPath = "/root/tmp"
$openvpnScriptPath = "/usr/local/openvpn_as/scripts"
$localCertPath = ""
$encryptedPassword =  Get-Content -Path 'c:\pathToEncryptFiles\root.txt' | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PSCredential (“root”, $encryptedPassword)


$sshsession = New-SSHSession -ComputerName $openvpnIP -Credential $creds -Force
$sftpsession = New-SFTPSession -ComputerName $openvpnIP -Credential $creds -Force
$certFiles = "cs.priv_key","cs.ca_bundle","cs.cert"

foreach($file in $certFiles) 
{ 
    Set-SFTPItem -SFTPSession $sftpsession -Destination '/root/tmp' `
                 -Path $localCertPath\$file -Force 
}

$sftpsession.Disconnect()

foreach($file in $certFiles) 
{ 
    Invoke-SSHCommand -SSHSession $sshsession `
        -Command "$openvpnScriptPath/scripts/sacli  --key $file' --value_file '$openvpnCertPath/$file' ConfigPut"
}
$restart = Invoke-SSHCommand -SSHSession $sshsession -Command "$openvpnScriptPath/sacli start"
$sshsession.Disconnect()

$restart.output