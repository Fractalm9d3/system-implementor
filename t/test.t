sub RunTests {
  my ($self,%args) = @_;
  # $self->TestMakeSingularAndMakePlural();
  # $self->TestSingularPAndPluralP();
  $self->TestMatcher();
  # $self->TestExceptions();
}

sub TestMakeSingularAndMakePlural {
  my ($self,%args) = @_;
  print Dumper
    ({
      Plural => $self->MyParser->MyUtil->MakePlural(Item => "Dog"),
      Singular => $self->MyParser->MyUtil->MakeSingular(Item => "Dogs"),
     });
}

sub TestSingularPAndPluralP {
  my ($self,%args) = @_;
  print Dumper($self->MyParser->MyUtil->SingularP(Item => "DOG"));
  print Dumper($self->MyParser->MyUtil->SingularP(Item => "DOGS"));
  print Dumper($self->MyParser->MyUtil->PluralP(Item => "DOG"));
  print Dumper($self->MyParser->MyUtil->PluralP(Item => "DOGS"));
}

sub TestMatcher {
  my ($self,%args) = @_;
  my $tests =
    [
     ["BOAT","<SINGULAR>",1],
     ["BOAT","<PLURAL>",0],
     ["BOATS","<SINGULAR>",0],
     ["BOATS","<PLURAL>",1],
     ["LOVE -ED","<PAST-TENSE-VERB>",1],
     ["BORING","<PAST-TENSE-VERB>",0],
    ];
  foreach my $test (@$tests) {
    my $res = $self->MyMatcher->MatchType
      (
       Input => $test->[0],
       Type => $test->[1],
      );
    print Dumper($res);
  }
}

sub TestExceptions {
  my ($self,%args) = @_;
  my $tests =
    [
     ["VALUES","<PLURAL>",1],
    ];
  foreach my $test (@$tests) {
    my $res = $self->MyMatcher->MatchType
      (
       Debug => $self->Debug,
       Input => $test->[0],
       Type => $test->[1],
      );
    print Dumper($res);
  }
}
