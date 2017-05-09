:: StraightenTheta
:: Created by Scott Kingery
:: techlifeweb.com
:: -------------------------
:: This batch file assumes you have connected your Theta S to your computer and copied all the image files to 
:: the PHOTOPATH folder you specify below. It will then will loop through all the jpg files in that folder and straighten them.
:: The new file will have str added to the name. Example: R0010260.jpg becomes R0010260-str.jpg
:: The original file is moved to a folder called Processed that will be created if necessary under your PHOTOPATH folder
:: -----------------------
:: This batch file requires you first install the Hugin photo processing software for Windows
:: Download that software from here: http://hugin.sourceforge.net/download/
:: Also required is ExifTool by Phil Harvey. Hugin comes with ExifTool but I like to have the latest one from here:
:: http://owl.phy.queensu.ca/~phil/exiftool/
:: You MUST update the paths that are used on your system. See the notes below
:: ---------------------------
@echo off
SetLocal ENABLEDELAYEDEXPANSION
::Put the path to your hugin program here
set hughinpath=C:\Program Files (x86)\Hugin\bin

::Put the path to ExifTool here
set exiftoolpath=D:\OneDrive\Programs\ExifTool

::Put the path to the pictures you want to straighten here
set photopath=E:\Imported\360ToProcess
if not exist "%photopath%\processed" md "%photopath%\processed"

::No further edits needed. 
for  %%f in ("%photopath%\*.jpg") do (

	"%exiftoolpath%\exiftool" -s -s -s -ricohpitch "%%f" > .\pitch.txt
	"%exiftoolpath%\exiftool" -s -s -s -ricohroll "%%f" > .\roll.txt
	for /f "delims=" %%a in (pitch.txt) do set pitch=%%a
	for /f "delims=" %%a in (roll.txt) do set roll=%%a
	set image=%%f
	call :procpitchroll
	"%hughinpath%\autooptimiser" -n -o temp.pto temp.pto
	"%hughinpath%\pano_modify" --canvas=AUTO --crop=AUTO -o temp.pto temp.pto
	"%hughinpath%\nona" -m JPEG -o %%~dpf%%~nf-str temp.pto
	
	"%exiftoolpath%\exiftool" -args -G --filename --directory "%%f" > out.args
	"%exiftoolpath%\exiftool" -overwrite_original -@ out.args -PosePitchDegrees=0 -PoseRollDegrees=0 %%~dpf%%~nf-str.jpg
	move "%%f" "%photopath%\processed\"

	)
	
:done
del "%photopath%\pitch.txt"
del "%photopath%\roll.txt"
del "%photopath%\out.args"
del "%photopath%\temp.pto"

goto:eof

:procpitchroll
	"%hughinpath%\pto_gen" -o temp.pto "%image%"
	"%hughinpath%\pto_var" --set=y=0,p=%pitch%,r=%roll%  -o temp.pto temp.pto


	
:eof
