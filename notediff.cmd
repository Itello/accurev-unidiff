@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15

use File::Temp;            #rmtree
use File::Spec::Functions; #catfile
use File::Basename;

if ($#ARGV != -1) {
    print "\nDoes not take input arguments!\n";
    exit;
}

$targetFile = new File::Temp( UNLINK => 0 );
open TARGET, ">$targetFile" or die "Could not open $targetFile for writing: $!\n";

# Run unidiff in same directory
$dirname = dirname(__FILE__);
$unidiffpath = "${dirname}\\unidiff.cmd";
@difference = `$unidiffpath`;

print TARGET @difference or die "Could not write to $targetFile: $!\n";

system("C:\\Program Files (x86)\\Notepad++\\notepad++.exe", "-ldiff", $targetFile);

__END__
:endofperl