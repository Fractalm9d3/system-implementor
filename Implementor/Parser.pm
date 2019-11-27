package Implementor::Parser;

use Implementor::Util;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyCodeBuilder MyUtil MyMatcher Patterns Rules Success Failure
   Debug RuleOverrides /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Success
    ({
      Success => 1,
     });
  $self->Failure
    ({
      Success => 0,
     });
  $self->MyCodeBuilder
    ($args{CodeBuilder});
  $self->MyUtil
    (Implementor::Util->new);
  $self->Debug($args{Debug} || 0);
  $self->LoadData;
}

sub Execute {
  my ($self,%args) = @_;

}

sub LoadData {
  my ($self,%args) = @_;
  my $patterns =
    {

     '<SINGULAR-MODULENAME> CAN BE <UNKNOWN>.' =>
     {
      Active => 0,
      Sample => 'OFCS CAN BE CURRENCY SYSTEM.',
      "find-or-create module OFCS" => 1,
      "? currency system" => 1,
     },

     '<PLURAL-MODULENAME> CAN BE CONSTITUTED_OF_OR_FILLED_WITH <SINGULAR-MODULENAME>.' =>
     {
      Active => 1,
      Sample => 'UNITS CAN BE CONSTITUTED_OF_OR_FILLED_WITH VALUE.',
      Action => sub {
	my %args = @_;
	my $res1 = $self->GetItemFromMapping
	  (
	   Name => "<PLURAL-MODULENAME>",
	   Mapping => $args{Mapping},
	  );
	return unless scalar @$res1;
	my $modulename1 = $self->MyUtil->MakeSingular(Item => $res1->[0]);
	my $module1 = $self->MyCodeBuilder->CodeBuilderFindOrCreateModule
	  (
	   ModuleName => $modulename1,
	   Namespace => $args{Namespace},
	  );

	my $res2 = $self->GetItemFromMapping
	  (
	   Name => "<SINGULAR-MODULENAME>",
	   Mapping => $args{Mapping},
	  );
	return unless scalar @$res2;
	my $modulename2 = $self->MyUtil->MakeSingular(Item => $res2->[0]);
	my $module2 = $self->MyCodeBuilder->CodeBuilderFindOrCreateModule
	  (
	   ModuleName => $modulename2,
	   Namespace => $args{Namespace},
	  );
      },
     },

     '<PLURAL-MODULENAME> CAN BE <SINGULAR-MODULENAME>.' =>
     {
      Sample => 'UNITS CAN BE ANONYMOUS.',
      Action => sub {
	my %args = @_;
	my $res1 = $self->GetItemFromMapping
	  (
	   Name => "<PLURAL-MODULENAME>",
	   Mapping => $args{Mapping},
	  );
	return unless scalar @$res1;
	my $modulename1 = $self->MyUtil->MakeSingular(Item => $res1->[0]);
	my $module1 = $self->MyCodeBuilder->CodeBuilderFindOrCreateModule
	  (
	   ModuleName => $modulename1,
	   Namespace => $args{Namespace},
	  );

	my $res2 = $self->GetItemFromMapping
	  (
	   Name => "<SINGULAR-MODULENAME>",
	   Mapping => $args{Mapping},
	  );
	return unless scalar @$res2;
	my $modulename2 = $self->MyUtil->MakeSingular(Item => $res2->[0]);
	my $module2 = $self->MyCodeBuilder->CodeBuilderFindOrCreateModule
	  (
	   ModuleName => $modulename2,
	   Namespace => $args{Namespace},
	  );
      },
      "find-or-create module Unit" => 1,
      "make inherited module Unit/Anonymous" => 1, # use Moose Roles here
      "? create attribute for Unit called Types and add \"Anonymous\"" => 1,
     },

     '<PLURAL-MODULENAME> MAY BE <PAST-TENSE-VERB>.' =>
     {
      Sample => 'DEBITS MAY BE APPLY -ED.',
      Action => sub {
	my %args = @_;
	my $res1 = $self->GetItemFromMapping
	  (
	   Name => "<PLURAL-MODULENAME>",
	   Mapping => $args{Mapping},
	  );
	return unless scalar @$res1;
	my $modulename1 = $self->MyUtil->MakeSingular(Item => $res1->[0]);
	my $module1 = $self->MyCodeBuilder->CodeBuilderFindOrCreateModule
	  (
	   ModuleName => $modulename1,
	   Namespace => $args{Namespace},
	  );

	my $res2 = $self->GetItemFromMapping
	  (
	   Name => "<SINGULAR-MODULENAME>",
	   Mapping => $args{Mapping},
	  );
	return unless scalar @$res2;
	my $modulename2 = $self->MyUtil->MakeSingular(Item => $res2->[0]);
	my $module2 = $self->MyCodeBuilder->CodeBuilderFindOrCreateModule
	  (
	   ModuleName => $modulename2,
	   Namespace => $args{Namespace},
	  );
      },
      "find-or-create module Debit" => 1,
      "create function in Debit called Apply" => 1,
     },

     '<PLURAL-MODULENAME> CAN BE CONSTITUTED_OF_OR_FILLED_WITH <PLURAL-MODULENAME>.' =>
     {
      Sample => 'ACCOUNTS CAN BE CONSTITUTED_OF_OR_FILLED_WITH INDIVIDUALS.',
      "find-or-create module Account" => 1,
      "find-or-create module Individual" => 1,
      "create collection called Individuals in Account having type Individual" => 1,
      "create function in Account called Fill with an argument of an array having type Individual, which adds to the collection Individuals" => 1,
     },

     '<PLURAL-MODULENAME> MAY BE <PAST-TENSE-VERB> FROM AN ACCOUNT.' =>
     {
      Active => 0,
      Sample => 'CREDITS MAY BE TRANSFER -ED FROM AN ACCOUNT.',
      "find-or-create module Account" => 1,
      "find-or-create module Credit" => 1,
      "# this isn't quite right, is it? create function in Account called Transfer with an argument of an array having type Credit" => 1,
     },

     '<SINGULAR-MODULENAME> CAN BE IN A SYSTEM.' =>
     {
      Active => 0,
      Sample => 'CASH CAN BE IN A SYSTEM.',
      "either figure out if system refers to something else, or" => 1,
      "find-or-create module System" => 1,
      "create attribute of System called Cash" => 1,
     },

     '<SINGULAR-MODULENAME> CAN BE A <SINGULAR-MODULENAME> OF AN EVENT.' =>
     {
      Active => 0,
      Sample => 'CREDIT CAN BE A RECORD OF AN EVENT.',
      "find-or-create module Credit" => 1,
      "find-or-create module Record" => 1,
      "find-or-create module Event" => 1,
      "assert Credit isa Record" => sub {$self->CodeBuilderAssertModuleISA(ModuleName1 => $1,ModuleName2 => $2);},
      "make inherited module Record/Event" => 1,
      "? create attribute for Record called Types and add \"Event\"" => 1,
      "?" => 1,
     },

     '<SINGULAR-MODULENAME> MAY BE <PAST-TENSE-VERB> BY <SINGULAR-MODULENAME>.' =>
     {
      Sample => 'CASH MAY BE REPLACE -ED BY DOCUMENTATION.',
      "find-or-create module Cash" => 1,
      "find-or-create module Documentation" => 1,
      "? create function in Cash called Replace with an argument of type Documentation" => 1,
      "? create function in Documentation called Replace with an argument of type Cash" => 1,
     },

     'A <SINGULAR-MODULENAME> MAY BE <PAST-TENSE-VERB>.' =>
     {
      Sample => 'A REPRESENTATION MAY BE NEED -ED.',
      "find-or-create module Representation" => 1,
      "create attribute of Representation called Need (ed?)" => 1,
     },

     '<SINGULAR-MODULENAME> MAY BE <PAST-TENSE-VERB>.' =>
     {
      Sample => 'CREDIT MAY BE GENERATE -ED',
      "find-or-create module Credit" => 1,
      "create function in Credit called Generate (ed?)" => 1,
     },

     'A <SINGULAR-MODULENAME> CAN BE <ATTRIBUTE>.' =>
     {
      Sample => 'A REPRESENTATION CAN BE PHYSICAL.',
      Action => sub {
	print "hi da\n";
      },
      "find-or-create module Representation" => 1,
      "create attribute of Representation called IsPhysical" => 1,
     },

     'AN <SINGULAR-MODULENAME> MAY BE <PAST-TENSE-VERB> <STATE>.' =>
     {
      Sample => 'AN ACCOUNT MAY BE OPEN -ED UNDER A NAME.',
      "find-or-create module Account" => 1,
      "find-or-create module Name" => 1,
      "create function in Account called OpenedUnder with an argument of type" => 1,
     },

     'AN <SINGULAR-MODULENAME>[PERSON??] MAY HAVE AN <SINGULAR-MODULENAME>' =>
     {
      Sample => 'AN OFCS[PERSON??] MAY HAVE AN ACCOUNT.',
      "find-or-create module OFCS" => 1,
      "find-or-create module Account" => 1,
      "create attribute of OFCS called Account" => 1,
     },

     '<PLURAL-MODULENAME> MAY ENSURE <STATE>.' =>
     {
      Sample => 'BIOMETRICS MAY ENSURE IDENTITY SECURITY.',
      "find-or-create module Biometrics" => 1,
      "create function in Biometrics called EnsureIdentitySecurity" => 1,
      "create attribute in Biometrics called IdentitySecurityEnsured" => 1,
     },

     '<PLURAL-MODULENAME> CAN BE <ATTRIBUTE>.' =>
     {
      Sample => 'KEYS CAN BE PHYSICAL.',
      "find-or-create module Key" => 1,
      "make inherited module Key/Physical" => 1,
      "? create attribute for Value called Types and add \"Symbolic\"" => 1,
     },

     'SOME_NUMBER_OF <PLURAL-MODULENAME> MAY BE <PAST-TENSE-VERB>.' =>
     {
      Sample => 'SOME_NUMBER_OF RECORDS MAY BE AUDIT -ED.',
      "find-or-create module Record" => 1,
      "figure out where there are collections of type Record and add a function called Audit with an argument of an array of type Record" => 1,
     },

     '<SINGULAR-MODULENAME> MAY BE <PAST-TENSE-VERB> <STATE>.' =>
     {
      Sample => 'INFORMATION MAY BE KEEP -ED SECRET.',
      "find-or-create module Information" => 1,
      "?????" => 1,
     },

    };
  $self->Patterns($patterns);
  my $rules =
    {

     "<ATTRIBUTE>" => 1,
     "<MODULENAME>" => 1,
     # "<WORD>" => sub {
     #   my %args = @_;
     #   if ($args{Input} =~ /^\w+$/) {
     # 	 return $self->MyUtil->Success;
     #   } else {
     # 	 return $self->MyUtil->Failure;
     #   }
     # },
     "<WORD>" => 1,
     '<PAST-TENSE-VERB>' => sub {
       my %args = @_;
       return $self->MyMatcher->Match
	 (
	  Pattern => "<WORD> -ED",
	  Input => $args{Input},
	  Exact => 1,
	 );
     },

     # "<PLURAL-MODULENAME>" => ["<PLURAL>","<COMPOUND PLURAL>","A <PLURAL>","AN <PLURAL>","A <COMPOUND PLURAL>","AN <COMPOUND PLURAL>"],
     "<PLURAL-MODULENAME>" => ["<PLURAL>","<COMPOUND PLURAL>","A <PLURAL>","AN <PLURAL>"],
     # "<SINGULAR-MODULENAME>" => ["<SINGULAR>","<COMPOUND SINGULAR>","A <SINGULAR>","AN <SINGULAR>","A <COMPOUND SINGULAR>","AN <COMPOUND SINGULAR>"],
     "<SINGULAR-MODULENAME>" => ["<SINGULAR>","<COMPOUND SINGULAR>","A <SINGULAR>","AN <SINGULAR>"],
     "<STATE>" => 1,
     "<UNKNOWN>" => 1,
     # the rest

     "A <SINGULAR>" => sub {
       my %args = @_;
       return $self->MyMatcher->Match
	 (
	  Pattern => "A <SINGULAR>",
	  Input => $args{Input},
	  Exact => 1,
	 );
     },
     "AN <SINGULAR>" => sub {
       my %args = @_;
       return $self->MyMatcher->Match
	 (
	  Pattern => "AN <SINGULAR>",
	  Input => $args{Input},
	  Exact => 1,
	 );
     },
     "A <PLURAL>" => sub {
       my %args = @_;
       return $self->MyMatcher->Match
	 (
	  Pattern => "A <PLURAL>",
	  Input => $args{Input},
	  Exact => 1,
	 );
     },
     "AN <PLURAL>" => sub {
       my %args = @_;
       return $self->MyMatcher->Match
	 (
	  Pattern => "AN <PLURAL>",
	  Input => $args{Input},
	  Exact => 1,
	 );
     },

     "A <THING>" => 1,
     "AN <THING>" => 1,
     "A <THING>[PERSON??]" => 1,
     "A THING-REFERRED-TO" => 1,

     "<COMPOUND SINGULAR>" => sub {
       my %args = @_;
       # make sure it is compound
       if ($args{Input} =~ /\s/) {
	 # it could be compound
	 # now we want to make sure it is
	 my @item = split /\s+/, $args{Input};
	 if (scalar @item > 1) {
	   if ($item[0] !~ /^an?$/i) {
	     return $self->MyUtil->SingularP
	       (Item => $item[-1]);
	   } else {
	     return $self->MyUtil->Failure;
	   }
	 }
       }
       return $self->Failure;
     },

     "<COMPOUND PLURAL>" => sub {
       my %args = @_;
       # make sure it is compound
       if ($args{Input} =~ /\s/) {
	 # it could be compound
	 # now we want to make sure it is 
	 my @item = split /\s+/, $args{Input};
	 if (scalar @item > 1) {
	   if ($item[0] !~ /^an?$/i) {
	     return $self->MyUtil->PluralP
	       (Item => $item[-1]);
	   } else {
	     return $self->MyUtil->Failure;
	   }
	 }
       }
       return $self->Failure;
     },

     "<PLURAL>" => sub {
       my %args = @_;
       return $self->MyUtil->PluralP
	 (
	  Item => $args{Input},
	  Debug => $args{Debug},
	 );
     },

     "<SINGULAR>" => sub {
       my %args = @_;
       return $self->MyUtil->SingularP
	 (Item => $args{Input});
     },

     "SOME_NUMBER_OF <SUBJECT>" => 1,
     "UNKNOWN" => 1,
     '<ATTRIBUTE>.' => 1,
     '<STATE>.' => 1,

    };
  $self->RuleOverrides
    ([
      [
       'A <SINGULAR>',
       '<COMPOUND SINGULAR>',
       '<SINGULAR>',
      ],
      [
       'A <PLURAL>',
       '<COMPOUND PLURAL>',
       '<PLURAL>',
      ],
     ]);
  $self->Rules($rules);
}

sub GetItemFromMapping {
  my ($self,%args) = @_;
  my @list;
  foreach my $item (@{$args{Mapping}}) {
    if ($item->[0] eq $args{Name}) {
      push @list, $item->[1];
    }
  }
  return \@list;
}

1;
