use 5.010;
use strict;
use Test::More;
use autodie ':all';
use Test::Exception;

BEGIN {
  use_ok("Logging::Trivial") or BAIL_OUT "Couldn't use Logging::Trivial!";
}

diag( "Testing Logging::Trivial $Logging::Trivial::VERSION, Perl $], $^X" );

my $testoutput;
open my $ERROR, ">", \$testoutput;
$testoutput = '';
ok $Logging::Trivial::ERROR = $ERROR, "Can redirect output";

my $testLogFile = "test.log";
ok Logging::Trivial::setLogFile $testLogFile;

subtest "_levelnum", sub {
  is Logging::Trivial::_levelnum("DETAIL"), 4;
  is Logging::Trivial::_levelnum("ERROR"), 0;
  ok Logging::Trivial::setLevel("ERROR");
  is Logging::Trivial::_levelnum(), 0;
  done_testing;
};

subtest "_logMessage", sub {
  is Logging::Trivial::_logMessage("DETAIL"), '';
  done_testing;
};

subtest "setLevel ERROR", sub {
  is Logging::Trivial::setLevel("ERROR"),'ERROR', "level updating is ok";
  is INFO("Hi"), '', "INFO is supressed";
  is DEBUG("Hi"=>['foo']), '', "DEBUG is supressed";
  is WARN("Hi"), '', "WARN is supressed";
  is $testoutput, '', "No output";
  dies_ok {ERROR "BAD STUFF"} "Error is preserved";
  done_testing;
};

subtest "setlevel WARN", sub {
  is Logging::Trivial::setLevel("DEBUG"), 'DEBUG';
  $testoutput = '';
  is WARN("foo"), 1, "WARN is not suppressed";
  ok $testoutput =~ /WARN:\tfoo\n/;
  $testoutput = '';
  is DEBUG("foo"), 1, "DEBUG is not suppressed";
  ok $testoutput =~ /DEBUG:\tfoo\n/;
  dies_ok {ERROR} "Error is preserved by ERROR level";
  done_testing;
};

done_testing;
