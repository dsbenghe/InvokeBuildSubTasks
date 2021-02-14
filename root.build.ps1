param(
    [Parameter(Position=0)]
    [string[]]$Tasks,
 
    [Parameter(Position=1)]
    [string[]]$SubTasks,

    [string]$RootParam1

    # need to define the params for build and deploy to be able to pass them
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
 
# delete Tasks params - SubTasks become Tasks for child scripts
# clone the collection to ensure imutability
$PSBoundParameters.Remove("Tasks") | out-null
 
task build {
    # just delegates to build.build.ps1
    Invoke-Build -Task $SubTasks -File "src/build.build.ps1" @PSBoundParameters
}

task deploy {
    # just delegates to deploy.build.ps1
    Invoke-Build -Task $SubTasks -File "deploy/deploy.build.ps1" @PSBoundParameters
}
 
# Synopsis: Top level task.
task roottask {
    # some of the top level tasks may compose Tasks from the child scripts
    Write-Output "root task $RootParam1"
}
 
task . roottask