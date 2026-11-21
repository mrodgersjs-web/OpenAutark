$ErrorActionPreference='Stop'
$folder=Join-Path $env:RUNNER_TEMP 'dotnetpro-first-install/screens'
if (!(Test-Path -LiteralPath $folder)) { return }
Add-Type -AssemblyName System.Security.Cryptography.Pkcs
$b64=(Get-Content (Join-Path $PSScriptRoot 'recipient.pem') | Where-Object { $_ -notmatch '^-----' }) -join ''
$cert=[Security.Cryptography.X509Certificates.X509Certificate2]::new([Convert]::FromBase64String($b64))
if ($cert.HasPrivateKey) { throw 'Public recipient only.' }
$zip=Join-Path $env:RUNNER_TEMP 'dotnetpro-screenshots-plaintext.zip'
$out=Join-Path $env:RUNNER_TEMP 'dotnetpro-screenshots.p7m'
try {
  Compress-Archive -LiteralPath $folder -DestinationPath $zip
  $ci=[Security.Cryptography.Pkcs.ContentInfo]::new([IO.File]::ReadAllBytes($zip))
  $aes=[Security.Cryptography.Pkcs.AlgorithmIdentifier]::new([Security.Cryptography.Oid]::new('2.16.840.1.101.3.4.1.42'))
  $cms=[Security.Cryptography.Pkcs.EnvelopedCms]::new($ci,$aes)
  $cms.Encrypt([Security.Cryptography.Pkcs.CmsRecipient]::new($cert,[Security.Cryptography.RSAEncryptionPadding]::OaepSHA256))
  [IO.File]::WriteAllBytes($out,$cms.Encode())
} finally {
  if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip }
  $cert.Dispose()
}
