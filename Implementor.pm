package Implementor;

# ("created-by" "PPI-Convert-Script-To-Module")

use BOSS::Config;
use Implementor::CodeBuilder;
use Implementor::Matcher;
use Implementor::Parser;
use Lingua::EN::Tagger;
use PerlLib::SwissArmyKnife;

use File::Basename;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Conf Data Objects Subjects MyCodeBuilder MyParser
   MyMatcher MyTagger Verbosity Debug Sentences2File /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = q(
	-t			Run tests
	-s <file>...		Specification Files
	-o			Overwrite
	-c			Clear the Sayer Cache
	-d <debug>		Debug level
	--no-formalize		Run without the formalize step
);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf($self->Config->CLIConfig);
  # $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

  if (defined($self->Conf->{'-d'})) {
    $self->Debug($self->Conf->{'-d'});
  } else {
    $self->Debug(3);
  }
  print Dumper({Debug => $self->Debug});
  $self->Subjects({});
  $self->Objects({});
  $self->Data({});
  $self->MyCodeBuilder
    (Implementor::CodeBuilder->new
     (
     ));
  $self->MyParser
    (Implementor::Parser->new
     (
      CodeBuilder => $self->MyCodeBuilder,
     ));
  $self->MyMatcher
    (Implementor::Matcher->new
     (
      Rules => $self->MyParser->Rules,
      Debug => $self->Debug,
     ));
  $self->MyParser->MyMatcher($self->MyMatcher);
  $self->MyTagger(Lingua::EN::Tagger->new);
  $self->Sentences2File({});
}

sub Execute {
  my ($self,%args) = @_;
  $self->ParseDescription(%args);
}

sub ParseDescription {
  my ($self,%args) = @_;
  if (exists $self->Conf->{'-s'}) {
    my @sentences;
    foreach my $file (@{$self->Conf->{'-s'}}) {
      my $basename = basename($file);
      $basename =~ s/\.([^\.]+)$//;
      my $datfile = $file.".knext.dat";
      my $kbsfile = $file.".knext.kbs";
      if (! -f $datfile) {
	my @extras;
	if ($self->Conf->{'-o'}) {
	  push @extras, "-o";
	}
	if ($self->Conf->{'-c'}) {
	  push @extras, "-c";
	}
	if ($self->Conf->{'--no-formalize'}) {
	  push @extras, "--no-formalize";
	}
	my $extras = join(" ",@extras)." ";
	my $command = '/var/lib/myfrdcsa/codebases/minor/free-knext/knext.pl '.$extras.
	  '-s "every few sentences" -f '.$file;
	print "$command\n";
	system $command;
	if (! -f $datfile) {
	  print "ERROR: ran knext but no result for $file\n";
	  next;
	}
      }
      my $item =  read_file_dedumper($datfile);
      # print Dumper($item);
      foreach my $entry1 (@$item) {
	foreach my $entry2 (@{$entry1->{ExtractedKnowledge}}) {
	  push @sentences, $entry2->{Sentence};
	  $self->Sentences2File->{$entry2->{Sentence}} = $basename;
	}
      }
    }
    $self->ProcessSentences
      (
       Sentences => \@sentences,
      );
    $self->MyCodeBuilder->ExportCode;
  }
  if (exists $self->Conf->{'-t'}) {
    $self->RunTests();
  }
}

sub ProcessSentences {
  my ($self,%args) = @_;
  # we will deal with this in the proper way (Logic Form?, querying)
  # in the future, for now, just write a regex parser...  Well, maybe,
  # depending on the quality of the logic forms, we could load it into
  # KBS2, and then query it
  foreach my $sentence (@{$args{Sentences}}) {
    my $tagged = $self->MyTagger->add_tags($sentence);
    # print Dumper($tagged);
    if ($sentence =~ /^(.+) CAN BE (.+)$/) {
      $self->Data->{CanBe}->{$1}->{$2}++;
      # process the subject here
      $self->ProcessSubject(Subject => $1);
      $self->ProcessObject(object => $2);
    } elsif ($sentence =~ /^(.+) MAY BE (.+)$/) {
      $self->Data->{MayBe}->{$1}->{$2}++;
      $self->ProcessSubject(Subject => $1);
      $self->ProcessObject(object => $2);
    } elsif ($sentence =~ /^(.+) MAY ENSURE (.+)$/) {
      $self->Data->{MayEnsure}->{$1}->{$2}++;
      $self->ProcessSubject(Subject => $1);
      $self->ProcessObject(object => $2);
    }
    my @results;
    foreach my $pattern (keys %{$self->MyParser->Patterns}) {
      if ($self->Debug >= 1) {
	print "Pat:  $pattern\nSent: $sentence\n";
      }
      my $match = $self->MyMatcher->Match
	(
	 Input => $sentence,
	 Pattern => $pattern,
	);
      if ($match->{Success}) {
	push @results, $match;
      } else {
	# print Dumper({Result => $match});
      }
    }
    my $num = scalar @results;
    print Dumper({Results => \@results}) if $self->Debug >= 3;
    if ($num > 1) {
      next;
      print "Multiple matches: ".$results[0]->{Input}."\n" if $self->Debug >= 3;
      foreach my $match (@results) {
	print "\t".$match->{Pattern}."\n" if $self->Debug >= 3;
      }
    } elsif ($num == 1) {
      my $match = $results[0];
      my $pattern = $match->{Pattern};
      print "Unique match: ".$match->{Input}."\n" if $self->Debug >= 3;
      # print "\t$pattern\n";
      print Dumper($match) if $self->Debug >= 3;
      # okay now look up the code to handle this pattern and run it
      if (! exists $self->MyParser->Patterns->{$pattern}->{Active} or
	  $self->MyParser->Patterns->{$pattern}->{Active} != 0) {
	if (exists $self->MyParser->Patterns->{$pattern}->{Action}) {
	  print Dumper({
			Pattern => $pattern,
			Match => $match->{Result},
		       });
	  my $res = $self->MyParser->Patterns->{$pattern}->{Action}->
	    (
	     Mapping => $match->{Result},
	     Namespace => $self->Sentences2File->{$sentence},
	    );
	}
      }
    } else {
      next;
      print "No matches: ".$sentence."\n\n";
    }
  }
}

sub ProcessSubject {
  my ($self,%args) = @_;
  $self->Subjects->{$args{Subject}}++;
}

sub ProcessObject {
  my ($self,%args) = @_;
  $self->Objects->{$args{object}}++;
}

1;
