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

if ($#ARGV != 0) {
    print "\nNeed to supply the current streams backing stream as single argument!\n";
	print "This is the name of the stream with correct case, for example Inca_13.3_Dev\n";
    exit;
}

# The original stream we want to diff againts
$basis_stream=join(' ', @ARGV);

# workspaceBasis is the new (sub)stream
@info = `accurev info`;
for (@info) {
	if (m!Basis:\s+(.+)!) {
		$workspaceBasis = $1;
	}
}

@promotediffed = `accurev diff -a -v "$workspaceBasis" -V "$basis_stream" -- -u4`;

# Empty file to diff new files against
$emptyFilePath = new File::Temp( UNLINK => 1 );
open emptyFile, ">$emptyFilePath" or die "Could not open $emptyFilePath for writing: $!\n";
print emptyFile '';

# Looks like this: "/./Inca/Source/java/core/src/main/java/se/itello/inca/FooBar.java created"
# Need to make it look like: "./Inca/Source/java/core/src/main/java/se/itello/inca/FooBar.java"
for (@promotediffed) {
	if (m!(\./.*\.(?:java|sql|xml)) created$!) {
		$newFilePath = $1;

		@newFileDiff = `diff -u4 $emptyFilePath "$newFilePath"`;
		print @newFileDiff;
	}
}

print '';
print @promotediffed;

__END__
:endofperl
