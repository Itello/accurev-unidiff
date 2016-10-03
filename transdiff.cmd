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

if ($#ARGV != 2) {
    print "\nShows diff in stream between transactions:\n";
	print "transdiff <stream/ws> <fromtrans> <totrans>\n";
    exit;
}

# The original stream we want to diff againts
$basis_stream=$ARGV[0];
$from_trans=$ARGV[1];
$to_trans=$ARGV[2];

@difflist = `accurev diff -a -i -v "$basis_stream" -V "$basis_stream" -t $from_trans-$to_trans`;

print @difflist;

# Empty file to diff new files against
$emptyFilePath = new File::Temp( UNLINK => 1 );
open emptyFile, ">$emptyFilePath" or die "Could not open $emptyFilePath for writing: $!\n";
print emptyFile '';

foreach $line (@difflist) {
	if ($line =~ m/.+ created/) {
		my ($file) = ($line =~ m/\/(.+) created/);
		@diff = `diff -u4 $emptyFilePath "$file"`;
		print @diff;
	} else {
		my ($file, $from_ver, $to_ver) = ($line =~ m/(.+) changed from (.+) to (.+)/);
		@diff = `accurev diff -v $to_ver -V $from_ver "$file" -- -u4`;
		print @diff;
	}
}

__END__
:endofperl