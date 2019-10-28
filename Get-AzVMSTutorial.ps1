# To replace the GetAzVMTutorial.ps1 we can group up and list all ResourceGroupNames explicitely as strings.
# This is just to prevent any faulty pipeline mechanisms further down the road.

$connectionName = "AzureRunAsConnection";
Write-Output "Connecting to AzureRM";

try {
  $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
  "Logging in to Azure..."
  Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch {
  if (!$servicePrincipalConnection) {
    $ErrorMessage = "Connection $connectionName not found."
    throw $ErrorMessage
  }
  else {
    Write-Error -Message $_.Exception
    throw $_.Exception
  }
}

# Looping through each resourcegroup seperately makes the script last long enough to count as a benchmark at the very least.
# If for whatever reason reporting needs to be sped up later on, this can be modified again.

$ResourceGroups = Get-AzureRmResourceGroup | Select-Object -ExpandProperty ResourceGroupName;

foreach($resourcegroupname in $ResourceGroups)
{
  Get-AzureRmVM -ResourceGroupName $resourcegroupname;
}