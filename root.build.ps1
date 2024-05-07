param(
    [Parameter(Position=0)]
    [string[]]$Tasks,
    [Parameter(Position=1)]
	[ArgumentCompleter({ MyArgumentCompleter @args })]
    [string[]]$SubTasks,
    [string]$RootParam1
)

dynamicparam {
	$DP = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
	$Tasks = $PSBoundParameters['Tasks']
	if (!$Tasks) {
		$Tasks = $dynamicparamTasks
	}
	if ($Tasks) {
		$skip = 'Tasks', 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'InformationAction', 'InformationVariable', 'ProgressAction'
		$map = @{deploy='deploy/deploy.build.ps1'; build='src/build.build.ps1'}
		foreach($currentTask in $Tasks) {
			$file = $map[$currentTask]
			if ($file) {
				$params = (Get-Command $file).Parameters
				foreach($p in $params.get_Values()) {
					if ($skip -notcontains $p.Name) {
						$DP[$p.Name] = New-Object System.Management.Automation.RuntimeDefinedParameter $p.Name, $p.ParameterType, $p.Attributes
					}
				}
			}
		}
	}
	$DP
}

process {
	function MyArgumentCompleter {
		param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
		$Tasks = $fakeBoundParameters['Tasks']
		if ($Tasks) {
			$map = @{deploy='deploy/deploy.build.ps1'; build='src/build.build.ps1'}
			foreach($task in $Tasks) {
				$file = $map[$task]
				if ($file) {
					(Invoke-Build ?? $file).get_Keys()
				}
			}
		}
	}
}

end {
	Set-StrictMode -Version Latest
	$ErrorActionPreference = 'Stop'

	# Ensure and call the module.
	if ([System.IO.Path]::GetFileName($MyInvocation.ScriptName) -ne 'Invoke-Build.ps1') {
		# bootstrap (removed for now)
		# ...

		#! hint for dynamicparam
		$dynamicparamTasks = $Tasks

		Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @PSBoundParameters
		return
	}

	# delete SubTasks, it does not exist in child scripts
	$MyParameters = $PSBoundParameters
	$null = $MyParameters.Remove("SubTasks")

	task build {
		# just delegates to build.build.ps1
		Invoke-Build -Task $SubTasks -File "src/build.build.ps1" @MyParameters
	}

	task deploy {
		# just delegates to deploy.build.ps1
		Invoke-Build -Task $SubTasks -File "deploy/deploy.build.ps1" @MyParameters
	}

	# Synopsis: Top level task.
	task roottask {
		# some of the top level tasks may compose Tasks from the child scripts
		Write-Output "root task $RootParam1"
	}

	task . roottask
}
