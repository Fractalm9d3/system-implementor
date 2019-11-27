package Implementor::Matcher;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Debug Rules Success Failure /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Rules($args{Rules});
  $self->Debug($args{Debug} || 0);
  $self->Success
    ({
      Success => 1,
     });
  $self->Failure
    ({
      Success => 0,
     });
}

sub Match {
  my ($self,%args) = @_;
  $args{Indentation} ||= "";
  $items = {};
  $iitems = {};
  my $i = $args{Input};
  my $p = $args{Pattern};
  # prepare pattern
  $counter = 1;
  $p =~ s/(<[^>]+>)/$self->CreateAssociation(Item => $1)/eg;
  $p =~ s/(\W)/\\$1/g;
  --$counter;
  foreach my $counter2 (1..$counter) {
    my $code = "ITEMITEM$counter2";
    $p =~ s/$code/(.+)/g;
  }
  print "$p\n" if $args{Verbosity}; # self->Debug;
  if ($args{Exact}) {
    $p = '^'.$p.'$';
  }
  if ($i =~ /$p/) {
    my $results = [];
    foreach my $counter2 (1..$counter) {
      my $code = "ITEMITEM$counter2";
      my $value = eval "\$".$counter2;
      if (defined $value) {
	# if (! defined $results->{$iitems->{$code}}) {
	# $results->{$iitems->{$code}} = [];
	# }
	push @$results, [$iitems->{$code},$value];
	# push @{$results->{$iitems->{$code}}}, eval "\$".$counter2;
      } else {
	return $self->Failure;
      }
    }

    # print Dumper({Results => $results});

    # have to check each of the data types
    foreach my $item (@$results) {
      my $type = $item->[0];
      my $input = $item->[1];
      # print Dumper({TypeInput => [$type,$input]});
      my $res = $self->MatchType
	(
	 Type => $type,
	 Input => $input,
	 Indentation => $args{Indentation}."\t",
	 Verbosity => $args{Verbosity},
	);
      if (! $res->{Success}) {
	return {
		Success => 0,
		Result => $res,
	       };
      }
    }
    return {
	    Success => 1,
	    Result => $results,
	    Input => $args{Input},
	    Pattern => $args{Pattern},
	   };
  }
  return $self->Failure;
}

sub MatchType {
  my ($self,%args) = @_;
  if ($args{Debug}) {
    $self->Debug($args{Debug});
  }
  $self->Indent
    (
     Indentation => $args{Indentation}, 
     Text => Dumper({MatchType => \%args}),
    );
  my $i = $args{Input};
  my $t = $args{Type};
  if (exists $self->Rules->{$t}) {
    my $ref = ref $self->Rules->{$t};
    if ($ref eq "") {
      if ($self->Rules->{$t} eq "1") {
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => "then I think anything goes\n",
	  );
	return $self->Success;
      } else {
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => "probably something like this (<PLURAL>|<COMPOUND SINGULAR>)\n",
	  );
	# can't handle this now, too hard
      }
    } elsif ($ref eq "ARRAY") {
      my @matches;
      foreach my $type (@{$self->Rules->{$t}}) {
	my $res = $self->MatchType
	  (
	   Input => $i,
	   Type => $type,
	   Indentation => $args{Indentation}."\t",
	  );
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => Dumper({Input => $i, Type => $type, Res => $res->{Success}}),
	   Level => 3,
	  );
	if ($res->{Success}) {
	  push @matches, $type;
	}
      }
      my $num = scalar @matches;
      if ($num > 1) {
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => "Multiple MatchType matches\n",
	  );
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => Dumper([$i,\@matches]),
	  );
      } elsif ($num == 1) {
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => "Unique MatchType match\n",
	  );
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => Dumper([$i,[$matches[0]]]),
	  );
	# print Dumper({Matches => \@matches});
	return {
		Success => 1,
		Matches => $matches[0],
	       };
      } elsif ($num == 0) {
	$self->Indent
	  (
	   Indentation => $args{Indentation},
	   Text => "No MatchType matches\n",
	  );
      }
    } elsif ($ref eq "CODE") {
      $self->Indent
	(
	 Indentation => $args{Indentation},
	 Text => "execute the code on the input and see if it is correct\n",
	);
      return $self->Rules->{$t}->
	(
	 Input => $i,
	 Debug => $self->Debug,
	);
    }
  } else {
    $self->Indent
      (
       Indentation => $args{Indentation},
       Text => "?\n",
      );
  }
  return $self->Failure;
}

sub CreateAssociation {
  my ($self,%args) = @_;
  my $item = $args{Item};
  $items->{$item} = "ITEMITEM$counter";
  $iitems->{"ITEMITEM$counter"} = $item;
  ++$counter;
  return $items->{$item};
}

sub Indent {
  my ($self,%args) = @_;
  $args{Level} ||= 1;
  if ($self->Debug >= $args{Level}) {
    print join("",map {$args{Indentation}.$_."\n"} split /\n/, $args{Text});
  }
}

1;
