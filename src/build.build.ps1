param(
    [Parameter(Position=0)]
    [string[]]$Tasks,
 
	[string]$BuildParam1,
	
	[string]$BuildParam2
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
    Write-Output "child 1 task 1 $BuildParam1"
}
 
task build-task2 {
    Write-Output "child 1 task 2 $BuildParam2"
}
 
# Synopsis: Default task.
task . task1, build-task2