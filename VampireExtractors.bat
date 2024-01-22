@echo off
setlocal enabledelayedexpansion
color 02
set ynconfig=y
set /a i=0
set /a sprites=0
set atlasname=none
set /a sprleft=0
set sprname=none
set /a percent=0
set /a x=0
set /a y=0
set /a w=0
set /a h=0

echo Welcome to VampireExtractors, an app to extract spritesheet atlases (.png-.json couples) encoded by
echo TexturePacker for Phaser3, such as pre-1.6 Vampire Survivors, and prepare them for combining back into atlas
echo.
echo				                         .,..            
echo				           .:,           .:kOo.          
echo				         'o0l   ':.  .':. .c0XOl'        
echo				       'lONNl   lXkclx00,  .kNX0Oo'      
echo				     .l0KXWW0c':0XKKKOKXko:;OMNK0X0o'    
echo				    .lKXNWMMWNXNMWNNNXNWMMNKNMMWXKXN0:   
echo				   .oXXWMMMWWWMMMMMWNNNWWMWWWWMMWNKXXO:  
echo				  .oKXWMMMWNWMMWK0NWNXXNWMMMWWWMMMNKKN0: 
echo				 .l0NNXXWWNWWOo:',OWWNNXdcdKWWNWNWWXKXW0'
echo				 ,KN0o'.cOXOc.    ,OMMNd.  'o0Kx;cxkKXNK,
echo				 ,0Xc    ,d,      .kWNx.     lx.   .;xX0,
echo				 ,kc      .       .:c'.      ,:.      ck,
echo				 'd'                                  ,x,
echo				  .                                   .c.
echo.                                         
echo				            .,,,,,,,,,,,,,,,,,;'         
echo				        .:ccxKKKKKKKKKKKKKKKKKK0occc:.   
echo				        .,,,,,,,,,,,,,,,,,,,,,,,,,,,,.   
echo.
echo For extraction to work, put this .bat file into atlas directory, for Vampire Survivors it being
echo "C:\Program Files (x86)\Steam\steamapps\common\Vampire Survivors\resources\app\.webpack\renderer\assets\img",
echo and input the name of atlas into prompt below.
echo.
set /p atlasname=Input atlas (.png-.json couple) name: 
cls

if not exist !atlasname!.json goto :nojson
if not exist !atlasname!.png goto :nopng

md !atlasname! >NUL 2>&1
copy !atlasname!.json !atlasname! >NUL 2>&1
cd !atlasname!
ren !atlasname!.json !atlasname!.txt >NUL 2>&1

for /f %%b in ('type !atlasname!.txt^|find /c "filename"') do set /a sprites=%%b

for /f "skip=12 tokens=2 delims={} " %%a in (!atlasname!.txt) do (
	if !sprleft! equ !sprites! goto :finish
	if !i! neq 15 (
		set /a i=!i!+1
		set out=%%a
	) else (
		copy ..\!atlasname!.png ..\!atlasname! >NUL 2>&1
		ren !atlasname!.png !sprname! >NUL 2>&1
		magick mogrify -crop !w!x!h!+!x!+!y! !sprname!
		cls
		set /a i=0
		set /a sprleft=!sprleft!+1
		set /a percent=100*!sprleft!/!sprites!
	)
	if !i! equ 1 (
		set out=!out:~1,-2!
		set sprname=!out!
		echo Processing !sprname!...
		set /a sprleft=!sprleft!+1
		echo Progress: !sprleft!/!sprites! (!percent!%%^)
		set /a sprleft=!sprleft!-1
	)
	if !i! equ 12 (
		set out=!out:~0,-1!
		set x=!out!
	)
	if !i! equ 13 (
		set out=!out:~0,-1!
		set y=!out!
	)
	if !i! equ 14 (
		set out=!out:~0,-1!
		set w=!out!
	)
	if !i! equ 15 (
		set h=!out!
	)
)

:finish
echo !sprites! sprites were successfully extracted into \!atlasname! directory.
set /p ynconfig=Do you want to make configs for packing the files back (recommended)? [Y/N]: 
if /i !ynconfig!==y goto :config
if /i !ynconfig!==n goto :end
cls
goto :finish

:config
cls
md config >NUL 2>&1
set /a i=0
set /a sprleft=0
set /a percent=0
for /f "skip=11 delims=" %%c in (!atlasname!.txt) do (
	set out=%%c
	set /a i=!i!+1
	if !i! equ 22 (
	set /a i=1
	set /a sprleft=!sprleft!+1
	set /a percent=100*!sprleft!/!sprites!
	cls
	)
	if !sprleft! equ !sprites! goto :finale
	if !i! equ 1 (
		set sprname=temp.txt
		copy /y NUL config\temp.txt >NUL 2>&1 
	)
	if !i! equ 2 (
		set sprname=!out:~18,-6!.txt
		ren config\temp.txt !sprname! >NUL 2>&1
		echo Creating config for !sprname!...
		echo Progress: !sprleft!/!sprites! (!percent!%%^)
	)
		echo  !out!>> config\!sprname!
)

:nojson
echo There was no !atlasname!.json found!
echo Make sure VampireExtractors is in your atlas' directory
goto :end

:nopng
echo There was no !atlasname!.png found!
echo Make sure VampireExtractors is in your atlas' directory
goto :end

:finale
echo !sprites! sprites were successfully configured to be further turned back to atlas.
:end
del /q !atlasname!.txt >NUL 2>&1
echo.
echo Procedure finished!
pause
endlocal