@echo off
setlocal enabledelayedexpansion
color 02

set atlasname=none
set sprname=none
set txtname=none
set /a w=0
set /a h=0
set /a sx=0
set /a sy=0
set /a ox=0
set /a oy=2
set /a pastw=0
set /a totalw=2
set /a temph=2
set /a totalh=0
set yncustom=n
set auto=q
set /a i=0
set /a fimg=0
set /a pimg=0
set /a sprites=0
set /a sprleft=0
set /a percent=0

echo Welcome to VampireCombiners, an app to combine sprites into spritesheet atlases (.png-.json couples) for
echo Phaser 3 games such as pre-1.6 Vampire Survivors. It isn't as efficient as TexturePacker, but at least it is free.
echo If you have a more efficient solution, feel free to share it on respective GitHub page
echo.
echo				        .:cclooooooooooooooooooocccc:.   
echo				        ...'cxkkkkkkkkkkkkkkkkkd;....    
echo.				                                         
echo				                                       . 
echo				 .;.                                  ,x,
echo				 ,k;               ..        ..       ,x,
echo				 ,Ok'    .;.      .xOd:      cd.     ,kO,
echo				 ,KNx'  .o0l.     .kMM0:    'xO:..,:xKNK,
echo				 'OXXKdoONNN0c.. .oXWWWK:.'oKNNXk0NXXXNK,
echo				  ,ONNWMMWWWWNK0odXMWNNXK0XWWWWMMMWXKNXd.
echo				   ;kXNWMMWNWMMMWWMWNNNNWMMWNWMMMWXKXXd. 
echo				    ,kXNWMMMWWMMMMWWNWWWMMMWWMMMNXKNNd.  
echo				     ,OXXNWMNOdOWNKKK0KWNXOdKMWXKKXKo.   
echo				      'lOKNNd. .dNKOO0XKc...kWX0K0o'     
echo				        .o0Xl   ckc..:dk'  'kNKOo.       
echo				          'll'   .     .  'kX0l'         
echo				           .'           .:c:.           
echo				                         ..              
echo.				 

echo For extraction to work, put this .bat file into atlas directory, for Vampire Survivors it being
echo "C:\Program Files (x86)\Steam\steamapps\common\Vampire Survivors\resources\app\.webpack\renderer\assets\img",
echo and input the name of atlas folder into prompt below.
echo.
set /p atlasname=Input unpacked atlas' folder name: 
echo.

cd !atlasname!
cls
:q
echo If you haven't configured sprites upon extraction (and they should've been), you'll need to do it manually.
set /p yncustom=If you have unconfigured images, do any of them require custom spriteSourceSize? [Y/N]: 
echo.
if /i !yncustom!==y (
	echo Then it will be asked for each one. It resets to 0 so just press Enter without input if it isn't needed.
	goto :ok
)
if /i !yncustom!==n (
	echo Then configs for them will be automatically generated and assigned to be default (0^)
	goto :ok
)
cls
goto :q
:ok
echo.
echo Analysing future atlas data...
for %%x in (*.png) do (
	set /a fimg=!fimg!+1
	set /a sprites=!sprites!+1
	set sprname=%%x
	set txtname=!sprname:~0,-4!.txt
	set /a xalert=0

	for /F "tokens=3 delims=x " %%a in ( 'magick identify !sprname!' ) do (
		IF 1%%a NEQ +1%%a set /a xalert=1
	)
	if !xalert! equ 0 (
		for /F "tokens=3 delims=x " %%a in ( 'magick identify !sprname!' ) do (
			set w=%%a
		)
		for /F "tokens=4 delims=x " %%a in ( 'magick identify !sprname!' ) do (
			set h=%%a
			if !totalh! lss !h! set /a totalh=!h!
		)
	)
	if !xalert! equ 1 (
		for /F "tokens=4 delims=x " %%a in ( 'magick identify !sprname!' ) do (
			set w=%%a
		)
		for /F "tokens=5 delims=x " %%a in ( 'magick identify !sprname!' ) do (
			set h=%%a
			if !totalh! lss !h! set /a totalh=!h!
		)
	)
	
	set /a totalw=!totalw!+!w!+2
	if not exist config\!txtname! (
		echo It seems you have a custom unconfigured image in the folder: !sprname!
		set auto=a 
		copy /y NUL config\!txtname! >NUL 2>&1 
		echo				{>> config\!txtname!
		echo 					"filename": "!sprname!",>> config\!txtname!
		echo 					"rotated": false,>> config\!txtname!
		echo 					"trimmed": false,>> config\!txtname!
		echo 					"sourceSize": {>> config\!txtname!
		echo 							"w": !w!,>> config\!txtname!
		echo 							"h": !h!>> config\!txtname!
		echo 					},>> config\!txtname!
		echo 					"spriteSourceSize": {>> config\!txtname!
		if !yncustom!==y set /p sx=Input spriteSourceSize x of !sprname!: 
		if !yncustom!==y set /p sy=Input spriteSourceSize y of !sprname!: 
		echo 						"x": !sx!,>> config\!txtname!
		echo 						"y": !sy!,>> config\!txtname!
		echo 						"w": !w!,>> config\!txtname!
		echo 						"h": !h!>> config\!txtname!
		echo 					},>> config\!txtname!
		echo 					"frame": {>> config\!txtname!
		echo 						"x": 1,>> config\!txtname!
		echo 						"y": 1,>> config\!txtname!
		echo 						"w": !w!,>> config\!txtname!
		echo 						"h": !h!>> config\!txtname!
		echo 					}>> config\!txtname!
		echo 				},>> config\!txtname!
		echo 		>> config\!txtname!
		set /a sx=0
		set /a sy=0
	)
)
set /a totalh=!totalh!+4

md pack >NUL 2>&1 
copy /y NUL pack\!atlasname!.txt >NUL 2>&1 
echo {>> pack\!atlasname!.txt
echo 	"textures": [>> pack\!atlasname!.txt
echo 		{>> pack\!atlasname!.txt
echo 			"image": "!atlasname!.png",>> pack\!atlasname!.txt
echo 			"format": "RGBA8888",>> pack\!atlasname!.txt
echo 			"size": {>> pack\!atlasname!.txt
echo 				"w": !totalw!,>> pack\!atlasname!.txt
echo 				"h": !totalh!>> pack\!atlasname!.txt
echo 			},>> pack\!atlasname!.txt
echo 			"scale": 1,>> pack\!atlasname!.txt
echo 			"frames": [>> pack\!atlasname!.txt

magick convert -size !totalw!x!totalh! xc:white pack\!atlasname!.png
magick convert pack\!atlasname!.png -transparent white pack\!atlasname!.png

for %%x in (*.png) do (
	set pimg=!pimg!+1
	set /a i=0
	set sprname=%%x
	set /a sprleft=!sprleft!+1
	set /a percent=100*!sprleft!/!sprites!
	cls
	echo Processing !sprname!...
	echo Progress: !sprleft!/!sprites! (!percent!%%^)
	set txtname=!sprname:~0,-4!.txt
	set /a ox=!ox!+!pastw!+2
	for /f "tokens=3 delims=x " %%a in ( 'magick identify !sprname!' ) do (
		set w=%%a
		set pastw=!w!
	)
	for /f "tokens=4 delims=x " %%a in ( 'magick identify !sprname!' ) do (
		set h=%%a
	)

	for /f "delims=" %%b in (config\!txtname!) do (
		set /a i=!i!+1
		set out=%%b
		if !i! equ 6 (
			set out=						"w": !w!,
		)
		if !i! equ 7 (
			set out=						"h": !h!
		)
		if !i! equ 12 (
			set out=						"w": !w!,
		)
		if !i! equ 13 (
			set out=						"h": !h!
		)
		if !i! equ 16 (
			set out=						"x": !ox!,
		)
		if !i! equ 17 (
			set out=						"y": !oy!,
		)
		if !i! equ 18 (
			set out=						"w": !w!,
		)
		if !i! equ 19 (
			set out=						"h": !h!
		)
		if !i! equ 21 (
			if !fimg! equ !pimg! (
							set out=				}
			) else set out= 				},
		)
		echo !out!>> pack\!atlasname!.txt
	)
	magick convert pack\!atlasname!.png !sprname! -set colorspace sRGB -geometry +!ox!+!oy! -composite pack\!atlasname!.png
)

echo 			]>> pack\!atlasname!.txt
echo 		}>> pack\!atlasname!.txt
echo 	],>> pack\!atlasname!.txt
echo 	"meta": {>> pack\!atlasname!.txt
echo 		"app": "https://github.com/FerrariCold/VampireExtractors",>> pack\!atlasname!.txt
echo 		"version": "F U TexturePacker!">> pack\!atlasname!.txt
echo 	}>> pack\!atlasname!.txt
echo }>> pack\!atlasname!.txt
ren pack\!atlasname!.txt !atlasname!.json

cls
echo Procedure finished!
pause
endlocal