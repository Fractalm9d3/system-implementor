#!/usr/bin/perl -w

use BOSS::Config;

use PerlLib::SwissArmyKnife;
use Text::Pluralize;

$specification = q(
	-s <file>...		Specification Files
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $counter;
my $items;
my $iitems;
my $subjects = {};
my $objects = {};
my $data = {};
my $success = {
	       Success => 1,
	      };
my $failure = {
	       Success => 0,
	      };

sub ParseDescription {
  my %args = @_;
  if (exists $conf->{'-s'}) {
    my @sentences;
    foreach my $file (@{$conf->{'-s'}}) {
      my $datfile = $file.".knext.dat";
      my $kbsfile = $file.".knext.kbs";
      if (! -f $datfile) {
	system 'knext.pl -s "every few sentences" -f '.$sourcefile;
	if (! -f $datfile) {
	  print "ERROR: ran knext but no result for $sourcefile\n";
	  next;
	}
      }
      my $item =  read_file_dedumper($datfile);
      # print Dumper($item);
      foreach my $entry1 (@$item) {
	foreach my $entry2 (@{$entry1->{ExtractedKnowledge}}) {
	  push @sentences, $entry2->{Sentence};
	}
      }
    }
    # See({Sentences => \@sentences});
    ProcessSentences(Sentences => \@sentences);
  }
}

sub ProcessSentences {
  my %args = @_;
  # we will deal with this in the proper way (Logic Form?, querying)
  # in the future, for now, just write a regex parser...  Well, maybe,
  # depending on the quality of the logic forms, we could load it into
  # KBS2, and then query it
  foreach my $sentence (@{$args{Sentences}}) {
    if ($sentence =~ /^(.+) CAN BE (.+)$/) {
      $data->{CanBe}->{$1}->{$2}++;
      # process the subject here
      ProcessSubject(Subject => $1);
      ProcessObject(object => $2);
    } elsif ($sentence =~ /^(.+) MAY BE (.+)$/) {
      $data->{MayBe}->{$1}->{$2}++;
      ProcessSubject(Subject => $1);
      ProcessObject(object => $2);
    } elsif ($sentence =~ /^(.+) MAY ENSURE (.+)$/) {
      $data->{MayEnsure}->{$1}->{$2}++;
      ProcessSubject(Subject => $1);
      ProcessObject(object => $2);
    }
    my @results;
    foreach my $pattern (keys %$patterns) {
      my $match = Match(
			Input => $sentence,
			Pattern => $pattern,
		       );
      if ($match->{Success}) {
	push @results, $match;
      }
    }
    my $num = scalar @results;
    if ($num > 1) {
      print "Multiple matches: ".$results[0]->{Input}."\n";
      foreach my $match (@results) {
	print "\t".$match->{Pattern}."\n";
      }
    } elsif ($num == 1) {
      print "Unique match\n";
    } else {
      print "No matches: ".$sentence."\n\n";
    }
    if (0) {
      if (! exists $patterns->{$pattern}->{Active} or
	  $patterns->{$pattern}->{Active} != 0) {
	if (exists $patterns->{$pattern}->{Action}) {
	  my $res = $patterns->{$pattern}->{Action}->
	    (
	     Mapping => $match->{Result},
	    );
	  print Dumper($res);
	}
      }
    }
  }
  print Dumper([sort keys %$objects]);
}

sub ProcessSubject {
  my %args = @_;
  $subjects->{$args{Subject}}++;
}

sub ProcessObject {
  my %args = @_;
  $objects->{$args{object}}++;
}
