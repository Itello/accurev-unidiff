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

use File::Temp;
use Cwd;

if ($#ARGV != -1) {
    print "\nDoes not take input arguments!\n";
    exit;
}

$arinfo = `accurev info 2>nul`;
die "You are not logged in!\nRun: accurev login <user> <password>\n" if $arinfo =~ /Principal:\s*\(not logged in\)/;
($ws_root) = ($arinfo =~ /Top:\s*(\S+)/);
die "Unidiff must be run from within an AccuRev workspace.\n" unless $ws_root;
chdir($ws_root);

@keptdiffed = `accurev diff -k -b -- -u4`;
@moddiffed = `accurev diff -m -- -u4`;

# Empty file to diff new files against
$emptyFilePath = new File::Temp( UNLINK => 1 );
open emptyFile, ">$emptyFilePath" or die "Could not open $emptyFilePath for writing: $!\n";
print emptyFile '';

# Looks like this: "/./Inca/Source/java/core/src/main/java/se/itello/inca/FooBar.java created"
# Need to make it look like: "./Inca/Source/java/core/src/main/java/se/itello/inca/FooBar.java"
for (@keptdiffed) {
	if (m!(\./.*\.(?:java|sql|xml)) created$!) {
		$newFilePath = $1;

		@newFileDiff = `diff -u4 $emptyFilePath "$newFilePath"`;
		print @newFileDiff;
	}
}

print '';
print @keptdiffed;
print @moddiffed;

__END__
:endofperl
