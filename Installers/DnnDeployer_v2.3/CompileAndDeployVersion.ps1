#requires -version 4
<#
.SYNOPSIS
  Compile and Deploy my files
#>
 
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
 
#Set Error Action to Stop
$ErrorActionPreference = "Stop"


#----------------------------------------------------------[Declarations]----------------------------------------------------------
 
#Script Version
$Script:ScriptVersion = "1.0"

#region Functions
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Init {
	Clear-Host
	Set-Alias "msbuild" "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" -Scope Script
}

Function Build-Project($solution) {
	msbuild $solution /t:Rebuild /p:Configuration=Release
}

Function Copy-RequestedFiles($sourceFolder, $targetSubfolder, [string[]]$files) {
	$targetFolder = Join-Path $PSScriptRoot $targetSubfolder
	
	if (-not (Test-Path $targetFolder -PathType Container)) { md $targetFolder | Out-Null }
	$files | % {
		"$targetSubfolder\$_"
		Copy-Item "$sourceFolder\$_" $targetFolder -Force
	}
}

Function Cleanup-TargetFolders {
	Remove-Item "$PSScriptRoot\dnncmd" -Force -Recurse
	Remove-Item "$PSScriptRoot\DnnExtension" -Force -Recurse
}

Function BuildAll-Projects {
	Build-Project "$PSScriptRoot\..\..\BuildSrc\BuildToDnn\BuildToDnn.sln"
	Build-Project "$PSScriptRoot\..\..\BuildSrc\Deployer\Deployer.sln"
}

Function CopyOutputFrom-Projects {
	Copy-RequestedFiles -sourceFolder "$PSScriptRoot\..\..\BuildSrc\BuildToDnn\dev\dnncmd\bin\Release\Merged" `
						-targetSubfolder "dnncmd" -files "dnncmd.exe"

	Copy-RequestedFiles -sourceFolder "$PSScriptRoot\..\..\BuildSrc\Deployer\obj" -targetSubfolder "DnnExtension" -files "Deployer_*_Install.zip"
}
#endregion

#-----------------------------------------------------------[Initialize]-----------------------------------------------------------
Init

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Cleanup-TargetFolders
BuildAll-Projects
CopyOutputFrom-Projects
