<#
    .SYNOPSIS
        This Azure Automation runbook automates the scheduled shutdown and startup of AKS Clusters in an Azure subscription. 

    .DESCRIPTION
        This is a PowerShell runbook, as opposed to a PowerShell Workflow runbook.
	Note that the Automation Account will need RBAC permission on the Cluster (scoped directly or inherited) in order to
	perform the start/stop operation.

    .PARAMETER ResourceGroupName
        The name of the ResourceGroup where the AKS Cluster is located
    
    .PARAMETER AksClusterName
        The name of the AKS Cluster to
    
    .PARAMETER Operation
        Currently supported operations are 'start' and 'stop'
    
    .INPUTS
        None.

    .OUTPUTS
        Human-readable informational and error messages produced during the job. Not intended to be consumed by another runbook.
#>

Param(
    	[parameter(Mandatory=$true)]
	[String] $ResourceGroupName,
    	[parameter(Mandatory=$true)]
	[String] $AksClusterName,
    	[parameter(Mandatory=$true)]
	[ValidateSet('start','stop')]
    	[String]$Operation
)
	
try
{
	Disable-AzContextAutosave -Scope Process
		
	#System Managed Identity
	Write-Output "Logging into Azure using System Managed Identity"
	$AzureContext = (Connect-AzAccount -Identity).context
	$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
}
catch {
	Write-Error -Message $_.Exception
	throw $_.Exception
}

Write-Output "Performing $Operation"
switch -CaseSensitive ($Operation)
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
