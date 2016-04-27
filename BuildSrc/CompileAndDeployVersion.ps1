#requires -version 4
<#
.SYNOPSIS
  Enter description here
#>
 
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
 
#Set Error Action to Stop
$ErrorActionPreference = "Stop"


#----------------------------------------------------------[Declarations]----------------------------------------------------------
 
#Script Version
$Script:ScriptVersion = "1.0"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Copy-RequestedFiles($sourceFolder, [string[]]$files) {
	$files | % {
		$_
		Copy-Item "$sourceFolder\$_" "$PSScriptRoot\dnncmd" -Force
	}
}

#-----------------------------------------------------------[Initialize]-----------------------------------------------------------
Clear-Host

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$sourceFolder = "$PSScriptRoot\..\..\BuildSrc\BuildToDnn\dev\dnncmd\bin\Release"
"CommandLine.dll", "dnncmd.exe", "Newtonsoft.Json.dll", "RestSharp.dll" | % {
	$_
	Copy-Item "$sourceFolder\$_" "$PSScriptRoot\dnncmd" -Force
}

$sourceFolder = "$PSScriptRoot\..\..\BuildSrc\Deployer\obj"
"Deployer_*_Install.zip" | % {
	$_
	Copy-Item "$sourceFolder\$_" "$PSScriptRoot\DnnExtension" -Force
}
