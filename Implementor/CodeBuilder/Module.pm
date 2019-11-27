package Implementor::CodeBuilder::Module;

use IO::File;
use File::Basename;
use Manager::Dialog qw(ApproveCommands);
use MyFRDCSA qw(ConcatDir);
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ModuleName ModuleTemplate ISAs Uses Attributes Functions /

  ];

sub init {
  my ($self,%args) = @_;
  my $modulename = $args{ModuleName};
  my $moduletemplate =<<EOM;
package <PACKAGENAME>;

<USES>

<ISA>

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / <ATTRIBUTES> /

  ];

<INITFN>

<EXECUTEFN>

<FUNCTIONS>

<DESTROYFN>

1;
EOM

  $self->ModuleName($modulename);
  $self->ModuleTemplate($moduletemplate);
  $self->Uses({});
  $self->ISAs({});
  $self->Attributes({});
  $self->Functions({});
  foreach my $functionname (qw(init Execute DESTROY)) {
    $self->Functions->{$functionname} = {
					 Contents => [],
					};
  }
}

sub FindOrCreateISA {
  my ($self,%args) = @_;
  $self->ISAs->{$args{ModuleName}} = 1;
}

sub FindOrCreateAttribute {
  my ($self,%args) = @_;
  $self->Attributes->{$args{AttributeName}} = 1;
}

sub ImportCode {
  my ($self,%args) = @_;

}

sub ExportCode {
  my ($self,%args) = @_;
  print "Exporting code ".$self->ModuleName."\n";
  # export the flags if this is the "Root Module"

  # possibly make a new minor codebase with all the trappings...

  # go ahead and generate the module text, and then spit it out into
  # the appropriate file

  # convert the modulename to a filename

  my $substitutions =
    {
     "<PACKAGENAME>" => $self->ModuleName,
     "<USES>" => join("\n",map {"use ".$_.";"} sort keys %{$self->Uses}),
     "<ISA>" => join("\n",map {"use ".$_.";"} sort keys %{$self->ISAs}),
     "<ATTRIBUTES>" => join(" ", sort keys %{$self->Attributes}),
     "<INITFN>" => $self->GetFunction(FunctionName => "init", Contents => $self->Functions->{"init"}->{Contents}),
     "<EXECUTEFN>" => $self->GetFunction(FunctionName => "Execute", Contents => $self->Functions->{"Execute"}->{Contents}),
     "<FUNCTIONS>" => join("\n", map {$self->GetFunction(FunctionName => $_, Contents => $self->Functions->{$_}->{Contents})} keys %{$self->Functions}),
     "<DESTROYFN>" => $self->GetFunction(FunctionName => "DESTROY", Contents => $self->Functions->{"DESTROY"}->{Contents}),
    };
  my $template = $self->ModuleTemplate;
  foreach my $key (keys %$substitutions) {
    $template =~ s/$key/$substitutions->{$key}/e;
  }
  # tidy it up
  # how ?  there were some code monkey perl cleaning things

  # make the containing directory if it doesn't exist

  my $dir = $args{ExportDirectory};
  my $outfile = ConcatDir($dir,$self->GetFilenameForModule);
  my $outdir = dirname($outfile);
  if (! -d $outdir) {
    my $command = "mkdir -p ".shell_quote($outdir);
    ApproveCommands
      (
       Commands => [$command],
       Method => "parallel",
       AutoApprove => 1,
      );
  }
  if (-d $outdir) {
    my $fh = IO::File->new;
    $fh->open(">$outfile") or die "cannot open outfile <$outfile>\n";
    print $fh $template;
    $fh->close();
    return 1;
  } else {
    print "failed to create outdir\n";
  }
}

sub GetFunction {
  my ($self,%args) = @_;
  my $functiontemplate = <<EOFUNCTION;
sub <FUNCTIONNAME> {
   my (\$self,\%args) = \@_;
<CONTENTS>
}
EOFUNCTION
  my $substitutions =
    {
     "<FUNCTIONNAME>" => $args{FunctionName} || "stub",
     "<CONTENTS>" => join("\n",@{$args{Contents}}) || "",
    };
  foreach my $key (keys %$substitutions) {
    $functiontemplate =~ s/$key/$substitutions->{$key}/e;
  }
  return $functiontemplate;
}

sub GetFilenameForModule {
  my ($self,%args) = @_;
  my $modulename = $self->ModuleName;
  $modulename =~ s/::/\//g;
  return $modulename.".pm";
}

1;
