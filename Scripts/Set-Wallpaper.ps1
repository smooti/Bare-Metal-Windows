Function Set-Wallpaper {
 
	<#
	 
		.SYNOPSIS
		Applies a specified wallpaper to the current user's desktop
		
		.PARAMETER WallpaperImage
		Path to desktop wallpaper
	 
		.PARAMETER Style
		Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)

		.PARAMETER LockScreenImage
		Path to lock screen wallpaper
	  
		.EXAMPLE
		Set-WallPaper -WallpaperImage "C:\Wallpaper\Default.jpg"
		Set-WallPaper -WallpaperImage "C:\Wallpaper\Background.jpg" -Style Fit
		Set-Wallpaper -LockScreenImage "C:\LockScreen\Default.jpg"
	  
	#>
	
	 
	param (
		[parameter(Mandatory = $False)]
		[string]$WallpaperImage,

		[parameter(Mandatory = $False)]
		[ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
		[string]$Style = 'Center',

		[parameter(Mandatory = $False)]
		[string]$LockScreenImage,

		[parameter(Mandatory = $False)]
		[switch]$System
	)

	if ($WallpaperImage) {
		if ($System) {
			$regKeyPath = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System'
		}
		else {
			$regKeyPath = 'HKCU:\\Control Panel\\Desktop\\'	# NOTE: This will set wallpaper for current user only
		}

		$wallpaperStyle = Switch ($Style) {
			'Center' { '0' }
			'Tile' { '1' }
			'Stretch' { '2' }
			'Fit' { '3' }
			'Fill' { '4' }
			'Span' { '5' }
	  
		}

		# Check if key exists, if not create it
		if (!(Test-Path $regKeyPath)) {
			New-Item $regKeyPath | Out-Null
		}

		# Add registry entries for system wide wallpaper
		New-ItemProperty -Path $regKeyPath -Name Wallpaper -PropertyType String -Value $WallpaperImage -Force | Out-Null
		New-ItemProperty -Path $regKeyPath -Name WallpaperStyle -PropertyType String -Value $wallpaperStyle -Force | Out-Null

		$code = @' 
using System.Runtime.InteropServices; 
namespace Win32{ 
    
     public class Wallpaper{ 
        [DllImport("user32.dll", CharSet=CharSet.Auto)] 
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ; 
         
         public static void SetWallpaper(string thePath){ 
            SystemParametersInfo(20,0,thePath,3); 
         }
    }
 } 
'@

		# Add .NET type to session
		Add-Type $code 

		#Apply the Change on the system without logging out user
		[Win32.Wallpaper]::SetWallpaper($WallpaperImage)
	}

	if ($LockScreenImage) {
		$regKeyPath = 'HKLM:\\Software\\Policies\\Microsoft\\Windows\\Personalization'
		# Check if key exists, if not create it
		if (!(Test-Path $regKeyPath)) {
			New-Item $regKeyPath | Out-Null
		}

		New-ItemProperty -Path $regKeyPath -Name LockScreenImage -Value $LockScreenImage | Out-Null
	}
	
}

Set-Wallpaper -WallpaperImage 'C:\windows\web\Wallpaper\APL-Wallpapers\wallpaper.jpg' -Style Fill -System
Set-Wallpaper -LockScreenImage 'C:\windows\web\Wallpaper\APL-Wallpapers\lockscreen.jpg'