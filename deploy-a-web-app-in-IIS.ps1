# Parameters
$siteName = "HelloWorldApp"
$appPoolName = "HelloWorldAppPool"
$userName = "DOMAIN\SpecifiedUser"  # Replace with the specified user
$httpsPort = 443
$certThumbprint = "‎THUMBPRINT_OF_YOUR_CERT"  # Replace with your certificate thumbprint
$groupName = "LocalGroupForApp"
$logPath = "C:\inetpub\logs\HelloWorldApp"
$appVirtualPath = "/MyApp"

# Import IIS module
Import-Module WebAdministration

# Step 1: Create the web application and set up the HTTPS binding
New-Item "IIS:\Sites\$siteName" -bindings @{protocol="https";bindingInformation="*:443:"} -physicalPath "C:\inetpub\wwwroot\$siteName"
Set-ItemProperty "IIS:\Sites\$siteName" -name applicationPool -value $appPoolName

# Add HTTPS binding with certificate
New-WebBinding -Name $siteName -IPAddress "*" -Port $httpsPort -Protocol https
$cert = Get-Item "Cert:\LocalMachine\My\$certThumbprint"
$bindingPath = "IIS:\SslBindings\0.0.0.0!$httpsPort"
New-ItemProperty -Path $bindingPath -Name CertificateHash -Value $cert.Thumbprint
New-ItemProperty -Path $bindingPath -Name CertificateStoreName -Value "My"

# Step 2: Create a local group and add user
New-LocalGroup -Name $groupName
Add-LocalGroupMember -Group $groupName -Member $userName

# Step 3: Create an application pool in IIS with the specified user
New-WebAppPool -Name $appPoolName
Set-ItemProperty IIS:\AppPools\$appPoolName -Name processModel.identityType -Value 3
Set-ItemProperty IIS:\AppPools\$appPoolName -Name processModel.userName -Value $userName
Set-ItemProperty IIS:\AppPools\$appPoolName -Name processModel.password -Value (Read-Host -Prompt "Enter Password" -AsSecureString)

# Step 4: Modify the path of the website log file
Set-ItemProperty "IIS:\Sites\$siteName" -Name logFile.directory -Value $logPath

# Step 5: Create a lower-level application and bind it to the application pool
New-WebApplication -Site $siteName -Name $appVirtualPath -PhysicalPath "C:\inetpub\wwwroot\$siteName$myApp" -ApplicationPool $appPoolName
