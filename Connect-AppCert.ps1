$clientId='56cb6a8c-92bc-484d-8919-b03af7cf4e80'
$tenantID='6b4b1b0d-23f1-4063-bbbd-b65e2984b893'
$Cert = ./src/Load-Cert.ps1
$certThumb=$Cert.Thumbprint
Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumb $certThumb
