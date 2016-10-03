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
use XML::Simple;
use Data::Dumper;

if ($#ARGV != 0) {
	print <<'EOT';

Shows diff for an issue:\n";
transdiff <issue>
	
Must be run from within a workspace which has all the files that have been
changed in the issue. E.g. a workspace under the stream to which the issue
was promoted.
EOT
    exit;
}

($ws_root) = (`accurev info 2>nul` =~ /Top:\s*(\S+)/);
die "Issuediff must be run from within an AccuRev workspace.\n" unless $ws_root;
chdir($ws_root);

$issue = $ARGV[0];

$xml = `accurev cpkdescribe -I $issue -fx`;
$ref = XMLin($xml, KeyAttr => {}, ForceArray => ['issue', 'element']);

$issues = $ref->{issues}->{issue};
foreach $issue (@$issues) {
	$elements_ref = $issue->{elements}->{element};

	# Empty file to diff new files against
	$emptyFilePath = new File::Temp( UNLINK => 1 );
	open emptyFile, ">$emptyFilePath" or die "Could not open $emptyFilePath for writing: $!\n";
	print emptyFile '';

	foreach $element (@$elements_ref) {
		$file = $element->{location};
		$type = $element->{elemType};
		$version = $element->{real_version};
		$basis = $element->{basis_version};

		next if $type eq 'dir';
		
		if ($basis eq '0/0') {
			@diff = `diff -u4 $emptyFilePath ".$file"`;
			print @diff;
		} else {
			@diff = `accurev diff -v $version -V $basis ".$file" -- -u4`;
			print @diff;
		}
	}
}

unlink emptyFile;

__END__
:endofperl