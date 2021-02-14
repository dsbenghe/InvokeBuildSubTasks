param(
    [Parameter(Position=0)]
    [string[]]$Tasks,
 
	[string]$Child2Param1,
	
	[string]$Child2Param2
)
 
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Ensure and call the module.
if ([System.IO.Path]::GetFileName($MyInvocation.ScriptName) -ne 'Invoke-Build.ps1') {
	$InvokeBuildVersion = '5.6.2'
	$ErrorActionPreference = 'Stop'
	try {
		Import-Module InvokeBuild -RequiredVersion $InvokeBuildVersion
	}
	catch {
		Install-Module InvokeBuild -RequiredVersion $InvokeBuildVersion -Scope AllUsers -Force
		Import-Module InvokeBuild -RequiredVersion $InvokeBuildVersion
	}
	Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @PSBoundParameters
	return
}
 
task task1 {
    Write-Output "child 2 task 1 $Child2Param1"
}
 
task child2task2 {
    Write-Output "child 2 task 2 $Child2Param2"
}
 
# Synopsis: Default task.
task . task1, child2task2