param(
  [Parameter(Mandatory=$true)]
  [String] $ResourceGroupName,

  [Parameter(Mandatory=$true)]
  [String] $AksClusterName,

  [Parameter(Mandatory=$true)]
  [ValidateSet('start','stop')]
  [String] $Operation
)

try
{
  Disable-AzContextAutosave -Scope Process
    
	#System Managed Identity
	$AzureContext = (Connect-AzAccount -Identity).context
  $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
}
catch {
  Write-Error -Message $_.Exception
  throw $_.Exception
}

switch -Exact ($Operation)
{
    'start'
    {
      Write-Output "Starting Cluster $AksClusterName in $ResourceGroupName"
      Start-AzAksCluster -ResourceGroupName $ResourceGroupName -Name $AksClusterName
    }
    'stop'
    {
      Write-Output "Stopping Cluster $AksClusterName in $ResourceGroupName"
      Stop-AzAksCluster -ResourceGroupName $ResourceGroupName -Name $AksClusterName
    }
	# 'toggle'
	# {
	# 	Write-Output "Toggling Cluster State of $AksClusterName in $ResourceGroupName"
	# 	Get-AzAksCluster -ResourceGroupName $ResourceGroupName -Name $AksClusterName | select -ExpandProperty ProvisioningState
	# 	Start-AzAksCluster -ResourceGroupName $ResourceGroupName -Name $AksClusterName
	# }
}
