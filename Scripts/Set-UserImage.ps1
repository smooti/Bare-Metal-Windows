function Set-UserImage {
	<#
	 
	.SYNOPSIS
	Applies a specified image to all new user account images
	
	.PARAMETER UserImage
	Path to user image
	
	
	.EXAMPLE
	Set-UserImage -UserImage "C:\UserImage\Default.jpg"
  
	#>
	 
	param (
		[parameter(Mandatory = $False)]
		[string]$UserImage

	)

	$defaultImagePath = "$env:programdata\Microsoft\User Account Pictures"
	# Take ownership of image and grant full control
	# NOTE: This is normally owned by 'Trusted Installer'
	takeown /f $defaultImagePath | Out-Null
	icacls $defaultImagePath /Grant "$($env:UserName):(F)" | Out-Null

	# Backup old image and set new image
	$imageName = $defaultImagePath.split('\')
	if (Test-Path "$defaultImagePath\$($imageName[-1])" -PathType Leaf) {
		Rename-Item -Path "$defaultImagePath\$($imageName[-1])" -NewName "$($imageName[-1]).bkp"
	}

	Copy-Item -Path $UserImage -Destination $defaultImagePath
}

Set-UserImage -UserImage "$env:windir\web\Wallpaper\Better-Images\users\user.png"
Set-UserImage -UserImage "$env:windir\web\Wallpaper\Better-Images\users\user-192.png"
Set-UserImage -UserImage "$env:windir\web\Wallpaper\Better-Images\users\user-48.png"
Set-UserImage -UserImage "$env:windir\web\Wallpaper\Better-Images\users\user-40.png"
Set-UserImage -UserImage "$env:windir\web\Wallpaper\Better-Images\users\user-32.png"