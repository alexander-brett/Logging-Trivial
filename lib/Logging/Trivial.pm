package Logging::Trivial;

use 5.010;
use strict;
use autodie;

use carp qw"";
use Data::Dumper;
use Scalar::Util qw"looks_like_number";
use Term::ANSIColor qw"colorstrip";

=head1 NAME

Logging::Trivial - The minimum useful logging

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Provides 5-level logging in a very straightforward manner:

 use Logging::trivial;
 Logging::trivial::setlevel("DEBUG");      # Only print messages at this level and above. Global setting.
 Logging::trivial::setLogFile("myScript.log"); # Print detailed logs to this file as well

 INFO "I'm giving an informative message"; # Methods write "LEVEL: thing" to STDERR
 DEBUG "Variable name" => {foo=>"bar"};    # DEBUG uses Data::Dumper to prettify a variable...
 DETAIL "A large variable I sometimes need" => [1,2,3,4,5]; # ...and so does DETAIL
 doSomething() if DEBUG;                   # Methods return 1 if that level is appropriate
 WARN "Careful how you do that, $user!";
 ERROR "Die with stack trace" if $someAwfulThingHappened;

=head1 EXPORT

Exports DETAIL, DEBUG, INFO, ERROR and WARN.

=cut

BEGIN {
  use Exporter;
  our @ISA = qw"Exporter";
  our @EXPORT = qw"DETAIL DEBUG INFO ERROR WARN";
}

=head1 SUBROUTINES/METHODS

=over 4

=item setLevel($nameOrNumber)

Sets the logging level - only messages at this level and above will be printed to STDERR.
Valid values, in order:

 0: ERROR
 1: WARN
 2: INFO
 3: DEBUG
 4: DETAIL

This function accepts numberical arguments so that you can use this with Getopt::Long
to get user-configurable debugging:

 use Logging::Trivial;
 use Getopt::Long;

 my $debugLevel = 2;
 GetOptions("d:+" => \$o);
 Logging::Trivial::setLevel($debugLevel);

Which allows invocation like:

 $> perl myscript.pl -dd

=cut

my $_Level = 'INFO';
my @_Levels = qw(ERROR WARN INFO DEBUG DETAIL);

sub setLevel {$_Level = looks_like_number($_[0]) ? $_Levels[$_[0]] : ($_[0] || $_Level);}

sub _levelnum {
  my ($val) = @_;
  for (0..$#_Levels) {
    return $_ if $_Levels[$_] eq ($val || $_Level)
  }
  return -1;
}

=item setLogFile($fileName)

When the log file is set, Logging::Trivial appends ALL messages to the file.
At the time that setLogFile is called, the file has NEW DEBUG LOG STARTING
followed by a timestamp, to distinguish subsequent runs.

=cut

my $_LogFileHandle;
our $ERROR = *STDERR; # this is ours so that test methods can override it
sub setLogFile {
  if (my $file = shift) {
    open $_LogFileHandle, '>>', $file;
    say $_LogFileHandle "NEW DEBUG LOG STARTING";
    say $_LogFileHandle scalar localtime;
  } else {
    say $ERROR "No log file provided"
  }
}


# _logMessage is a utility function which contains the shared logic for all of the
# logging functions

sub _logMessage {
  my ($level, $message, $detail) = @_;
  my $isValid = _levelnum($level) <= _levelnum();
  if ($message) {
    my $output = "$level:\t$message".($detail?"\n$detail":"");
    say $_LogFileHandle colorstrip $output if $_LogFileHandle;
    say $ERROR $output if $isValid;
  }
  return $isValid;
}

=item ERROR "string"

ERROR prints a log message like Carp::confess then dies with croak();

=cut

sub ERROR {
  my $message = shift;
  _logMessage "ERROR", $message . Carp::longmess();
  die $message || '';
}

=item WARN "string"

Used for non-fatal errors such as bad input or invalid credentials.

=cut

sub WARN {_logMessage "WARN", shift}

=item INFO "string"

Used to inform the user of the normal progress of the program. This is the default level.

=cut

sub INFO {_logMessage "INFO", shift}

=item DEBUG "output name" => $variable_reference

Used to print a dump of the variable mentioned using Data::Dumper for debugging.

=cut

sub DEBUG {
  my ($message, $variable) = @_;
  _logMessage "DEBUG", $message, Dumper($variable);
}

=item DETAIL "output name" => $variable_reference

Used to print extra-fine-detail logs for when DEBUG wasn't quite enough.

=cut

sub DETAIL {
  my ($message, $variable) = @_;
  _logMessage "DETAIL", $message, Dumper($variable);
}

1; # End of Logging::Trivial

__END__

=back

=head1 AUTHOR

Alexander Brett, C<< <alex at alexander-brett.co.uk> >>

=head1 BUGS

Please report any bugs at L<https://github.com/alexander-brett/Logging-Trivial/issues>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Logging::Trivial

You can also look for information at the github repository: L<https://github.com/alexander-brett/Logging-Trivial>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Alexander Brett.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut
