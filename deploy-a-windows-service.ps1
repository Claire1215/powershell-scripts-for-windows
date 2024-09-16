# Parameters
$serviceName = "MyFakeWindowsService"
$serviceDisplayName = "My Fake Windows Service"
$serviceDescription = "This is a fake service for deployment example."
$fakeExecutable = "C:\fake\fakeapp.exe"  # Fake executable file path
$userName = "DOMAIN\SpecifiedUser"  # Replace with the specified user
$recoveryAction = "Restart"
$delay = 60000  # 60 seconds

# Step 1: Create the Windows Service and point it to the fake executable
New-Service -Name $serviceName -BinaryPathName $fakeExecutable -DisplayName $serviceDisplayName -StartupType Automatic -Description $serviceDescription

# Step 2: Configure the service to run with the specified user
$service = Get-WmiObject win32_service -Filter "name='$serviceName'"
$service.Change($null, $null, $null, $null, $null, $null, $null, $userName, (Read-Host -Prompt "Enter Password" -AsSecureString))

# Step 3: Set the service startup type to auto-start
Set-Service -Name $serviceName -StartupType Automatic

# Step 4: Configure Error Recovery for the service
# Set recovery options to restart the service after 1 minute if it fails
sc.exe failure $serviceName reset= 60 actions= restart/$delay/restart/$delay/restart/$delay
