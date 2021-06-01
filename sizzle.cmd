@echo off
::Joe's sizzle 2.0
::Basically sizzle but it only works in a tools directory within a ReactOS source tree
::works more like razzle.cmd than sizzle.bat does.
::Expect a lot of parameter changes in this one compared to sizzle.bat
::Created 5-27-21
::Rewritten on 5-31-21

::TODO: add detection for whether or not we are running within a VS command prompt window. 
::TODO: add a way for the script to know what has or has not been executed,
::including asking to redirect build to configure to configure the source tree before executing build
::TODO: Add a execution date and time logger for all events executed...

::Variables
set solutionsGen=false
set configure=false
set build=false
set srcTree=%cd%
::set the two variables needed for ReactOS
set BISON_PKGDATADIR=%srcTree%\tools\RoSBE\share\bison
set M4=%srcTree%\tools\RoSBE\bin\m4.exe

::parameters that we can use
::help parameters
if "%1" == "help" goto Usage
if "%1" == "-?" goto Usage
if "%1" == "/?" goto Usage
if "%1" == "-help" goto Usage
if "%1" == "/help" goto Usage
::parameters
if /I "%1" == "genSolutions" set solutionsGen=true& set configure=false& set build=false& goto :generateSolutions
if /I "%1" == "configure" set configure=true& set solutionsGen=false& goto :configureSource
if /I "%1" == "build" set build=true& set solutionsGen=false& set configure=true& goto :buildSource
if /I "%1" == "state" goto :varStatus

::help menu
:Usage
echo ------------------------------------------------------------------------------------------------------------
echo Sizzle Help Menu
echo Valid Parameters:
echo 1. Help: displays parameters and info for sizzle.bat
echo 2. genSolutions: generate solutions for ReactOS and visual studio. 
echo 2. configure: Disables generation of Visual Studio solutions and runs configre.cmd to generate ReactOS Build Environment for MSVC
echo 3. build: Builds all components. See notes.
echo 4. makeImg: Generates disc images. Example: makeImg.cmd
echo 5. state: displays what variables are on or off, type sizzle_state for more info. 
::echo 4. makecd: generates the ISO images.
echo ------------------------------------------------------------------------------------------------------------
goto :exit

:: ---------------- MAIN CODE ------------------------------------------------------------------------------
::just all of our functions, not much else
:generateSolutions
mkdir %srcTree%\VSSolutions
pushd %srcTree%\VSSolutions
%srcTree%\configure.cmd VSSolution -DENABLE_ROSTESTS=1 -DENABLE_ROSAPPS=1
goto :exit

:configureSource
%srcTree%\configure.cmd
goto :exit

:buildSource
if %platform% == x64 (
    cd %srcTree%\output-vs-amd64
)
if %platform% == x86 (
    cd %srcTree%\output-vs-i386
)
%srcTree%\tools\RoSBE\bin\ninja.exe all
goto :makeCdExec

::generates the script to generate the disc images...
:makeCdExec
echo @echo off >> makeImg.cmd
echo ::Script auto generated by sizzle.cmd on completion of the build command. >> makeImg.cmd
echo ::Generated on %date% at %time% by sizzle.cmd in directory %srcTree%. >> makeImg.cmd
echo >> makeImg.cmd
echo ::Generate the disc images. >> makeImg.cmd
echo ninja hybridcd >> makeImg.cmd
goto :exit
::----------------------------------------------------------------------------------------------------------

:varStatus
echo BISON_PKGDATADIR=%BISON_PKGDATADIR%
echo M4=%M4%
echo solutionsGen=%solutionsGen%
echo configure=%configure%
echo build=%build%
echo srcTree=%srcTree%
echo srcTreeStatic=%srcTreeStatic%, use srcStatic_info for more info about this, or see notes. 
goto :exit

::just exits the program, simple
:exit
pause


::notes
::The build parameter could be eventually pushed to an external script and sizzle rewritten to behave
::more like razzle.cmd from Windows XP and Win2k3 build tools, and we might make the RoSBe just be
::included with the source tree and require sizzle to be in a certain directory, removing
::the need for directory parameters except for like a Visual Studio output directory for solutions...
::---------------------------------------------------------------------------------------------------
::ISO images, again, might be set into an external script to simplify sizzle and operate similar to the build
::parameter, we will see though. 


::these notes are useless mostly, but I will just keep them for preservation's sake
::variable notes and path structure
::our directory for this script will be as follows
::
::
::                                    |--sizzle.cmd--
::                                    |--RoSBE\--
::              |--Tools--------------|--makeCD.cmd--(possibly pointless)--
::              |                     |--build.cmd--(possibly pointless)--
::              |--buildInit.cmd----  |--add some special scripts as needed--
::-Ros Source---|--source code etc--
::
::
::buildInit.cmd: Would be useful, but variables are in sizzle so.. pointless I guess?
::Should we put RoSBE in the root of the source tree, dump its contents into tools or
::should we just put the RoSBE directory into the tools directory...
::
::
::