param(
    [Parameter(Position=0)]
    [string[]]$Tasks,

    [Parameter(Position=1)]
	[ArgumentCompleter({
		param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
		$task = $fakeBoundParameters['Tasks']
		if ($task) {
			$map = @{deploy='deploy/deploy.build.ps1'; build='src/build.build.ps1'}
			$file = $map[$task]
			if ($file) {
				(Invoke-Build ?? $file).get_Keys()
			}
		}
	})]
    [string[]]$SubTasks,

    [string]$RootParam1

    # need to define the params for build and deploy to be able to pass them
    # can we avoid to propagate these params from child scripts to the root script?
    # [string]$BuildParam1,

    # [string]$BuildParam2

    # [string]$DeployParam1,

    # [string]$DeployParam2
)
dynamicparam {
	$skip = 'Tasks', 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'InformationAction', 'InformationVariable'
	$DP = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
	$map = @{deploy='deploy/deploy.build.ps1'; build='src/build.build.ps1'}
	$Tasks = $PSBoundParameters['Tasks']
	foreach($task in $Tasks) {
		$file = $map[$task]
		if ($file) {
			$params = (Get-Command $file).Parameters
			foreach($p in $params.get_Values()) {
				if ($skip -notcontains $p.Name) {
					$DP[$p.Name] = New-Object System.Management.Automation.RuntimeDefinedParameter $p.Name, $p.ParameterType, $p.Attributes
				}
			}
		}
	}
	$DP
}
end {
	Set-StrictMode -Version Latest
	$ErrorActionPreference = 'Stop'

	# Ensure and call the module.
	if ([System.IO.Path]::GetFileName($MyInvocation.ScriptName) -ne 'Invoke-Build.ps1') {
		# bootstrap (removed for now)
		# ...
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
}
