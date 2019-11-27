package Implementor::Util;

use CodeMonkey::CamelCase;
use PerlLib::SwissArmyKnife;

use Lingua::EN::Inflect::Number qw(number to_S to_PL);
# use Lingua::Stem qw(stem);

use Text::Pluralize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyCamelCase Success Failure /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyCamelCase
    (
     # CodeMonkey::CamelCase->new(),
    );
  $self->Success
    ({
      Success => 1,
     });
  $self->Failure
    ({
      Success => 0,
     });
}

sub MakeCamelCase {
  my ($self,%args) = @_;
  return $self->MyCamelCase->GetBestCamelCase
    (
     Word => $args{Item},
    );
}

#   print number("goat");  # "s" - there's only one goat
#   print number("goats"); # "p" - there's several goats
#   print number("sheep"); # "ambig" - there could be one or many sheep

#   print to_S("goats");   # "goat"
#   print to_PL("goats");  # "goats" - it already is
#   print to_S("goat");    # "goat" - it already is
#   print to_S("sheep");   # "sheep"

sub PluralP {
  my ($self,%args) = @_;
  if ($args{Item} !~ /\s/ and number($args{Item}) eq "p") {
    return $self->Success;
  }
  return $self->Failure;
}

sub SingularP {
  my ($self,%args) = @_;
  if ($args{Item} !~ /\s/ and number($args{Item}) eq "s") {
    return $self->Success;
  }
  return $self->Failure;
}

sub MakePlural {
  my ($self,%args) = @_;
  return to_PL($args{Item});
}

sub MakeSingular {
  my ($self,%args) = @_;
  return to_S($args{Item});
}

# sub PluralP {
#   my ($self,%args) = @_;
#   my $a = lc($args{Item});
#   my $b = lc($self->MakePlural(Item => $args{Item}));
#   if ($args{Debug}) {
#     print Dumper
#       ({
# 	A => $a,
# 	B => $b,
#        });
#   }
#   if ($a eq $b) {
#     return $self->Success;
#   }
#   return $self->Failure;
# }

# sub SingularP {
#   my ($self,%args) = @_;
#   if (lc($args{Item}) eq lc($self->MakeSingular(Item => $args{Item}))) {
#     return $self->Success;
#   }
#   return $self->Failure;
# }

# sub MakePlural {
#   my ($self,%args) = @_;
#   my @res1 = stem($args{Item});
#   return pluralize($res1[0]->[0], 10);
# }

# sub MakeSingular {
#   my ($self,%args) = @_;
#   my @res1 = stem($args{Item});
#   return $res1[0]->[0];
# }

1;
