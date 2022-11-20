Function Set-Wallpaper {
 
	<#
	 
		.SYNOPSIS
		Applies a specified wallpaper to the current user's desktop
		
		.PARAMETER Image
		Provide the exact path to the image
	 
		.PARAMETER Style
		Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
	  
		.EXAMPLE
		Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
		Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
	  
	#>
	
	 
	param (
		[parameter(Mandatory = $True)]
		# Provide path to image
		[string]$Image,
		# Provide wallpaper style that you would like applied
		[parameter(Mandatory = $False)]
		[ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
		[string]$Style = 'Center'
	)

	$systemWallpaperPath = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System'
	$wallpaperStyle = Switch ($Style) {
		'Center' { '0' }
		'Tile' { '1' }
		'Stretch' { '2' }
		'Fit' { '3' }
		'Fill' { '4' }
		'Span' { '5' }
	  
	}

	$value = 0
	If ($Style -eq 'Tile') {
		$value = 1
	}

	if (!(Test-Path $systemWallpaperPath)) {
		New-Item $systemWallpaperPath | Out-Null
	}

	# Add registry entries for system wide wallpaper
	New-ItemProperty -Path $systemWallpaperPath -Name Wallpaper -PropertyType String -Value $Image -Force | Out-Null
	New-ItemProperty -Path $systemWallpaperPath -Name WallpaperStyle -PropertyType String -Value $wallpaperStyle -Force | Out-Null
	New-ItemProperty -Path $systemWallpaperPath -Name TileWallpaper -PropertyType String -Value $value -Force | Out-Null

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

	#Apply the Change on the system 
	[Win32.Wallpaper]::SetWallpaper($Image)
}

Set-Wallpaper -Image C:\windows\web\Wallpaper\wallpaper.png -Style Center