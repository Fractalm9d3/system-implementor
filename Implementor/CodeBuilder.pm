package Implementor::CodeBuilder;

use Implementor::CodeBuilder::Module;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyUtil Modules ExportDirectory /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyUtil($args{Util});
  $self->Modules({});
  $self->ExportDirectory
    ($args{ExportDirectory} || "/tmp/codebase");
}

sub Execute {
  my ($self,%args) = @_;
}

# CodeBuilder

sub CodeBuilderLocateCollection {
  # figure out where there are collections of type <collectiontype> and add a function called <functionname> with an argument of an array of type <moduletype>
  my ($self,%args) = @_;
}

sub CodeBuilderCreateCollection {
  # create collection called <collectionname(shouldbeplural)> in <module> having type <moduletype>
  my ($self,%args) = @_;
  my $module = $self->CodeBuilderFindOrCreateModule(ModuleName => $args{ModuleName});
  CreateCollection(
		   CollectionName => MakePlural(Item => $args{CollectionName}),
		   Type => $args{ModuleType},
		  );
}

sub CodeBuilderAssertModuleISA {
  # assert <module1> isa <module2>
  my ($self,%args) = @_;
  my $module1 = $self->CodeBuilderFindOrCreateModule(ModuleName => $args{ModuleName1});
  my $module2 = $self->CodeBuilderFindOrCreateModule(ModuleName => $args{ModuleName2});
  $module1->FindOrCreateISA(ModuleName => $args{ModuleName2});
}

sub CodeBuilderCreateAttribute {
  # ? create attribute for <module> called Types (containing a list) and add <Type>
  # create attribute in <module> called <restoffunctionname(Camelcase)>Ensured
  # create attribute of <module> called <attributename>
  # create attribute of <module> called <attributename>?ed
  my ($self,%args) = @_;
  my $module = $self->CodeBuilderFindOrCreateModule(ModuleName => $args{ModuleName});
  $module->FindOrCreateAttribute
    (
     AttributeName => $self->MyUtil->MakeCamelCase($args{RestOfFunctionName})."Ensured",
    );
  $module->FindOrCreateAttribute
    (
     AttributeName => $args{AttributeName},
    );
  $module->FindOrCreateAttribute
    (
     AttributeName => MakePastTense($args{AttributeName}),
    );
}

sub CodeBuilderFindOrCreateModule {
  # find-or-create module <module>
  my ($self,%args) = @_;
  $args{Namespace} =~ s/\W/_/g;
  $args{ModuleName} =~ s/\W/_/g;
  $args{ModuleName} = "Org::FRDCSA::Implementor::".$args{Namespace}."::".$args{ModuleName};
  if (! exists $self->Modules->{$args{ModuleName}}) {
    $self->Modules->{$args{ModuleName}} =
      Implementor::CodeBuilder::Module->new
	  (
	   ModuleName => $args{ModuleName},
	  );
  }
  return $self->Modules->{$args{ModuleName}};
}

sub CodeBuilderFindOrCreateModuleSimilarTo {
# find-or-create module similar to <modulename>
  my ($self,%args) = @_;
}

sub CodeBuilderCreateFunction {
  # ? create function in <module> called <functionname> with an argument of type <moduletype>
  # create function in <module> called Ensure<restoffunctionname(Camelcase)>
  # create function in <module> called <function name>
  # create function in <module> called <function name> with an argument of an array having type <type>, which adds to the collection <collectionname(shouldbeplural)>
  my ($self,%args) = @_;
}

sub CodeBuilderCreateInheritedModule {
  # make inherited module <module>/<submodule>
  my ($self,%args) = @_;
}

sub CodeBuilderPossibleModules {
  # ? <possible module> and what to do with it
  my ($self,%args) = @_;
}

# Code Import and Export

sub ImportCode {
  my ($self,%args) = @_;
  # build the abstract representation from the code
}

sub ExportCode {
  my ($self,%args) = @_;
  # on the basis of the description of the code, we will generate this
  print Dumper($self->Modules);
  foreach my $modulename (keys %{$self->Modules}) {
    $self->Modules->{$modulename}->ExportCode
      (
       ExportDirectory => $self->ExportDirectory,
       %args,
      );
  }
}

1;
