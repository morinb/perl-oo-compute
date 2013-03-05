package Math::Function;

use strict;
use warnings;
use Carp;

my $functions = {};

sub _new {
	my ($class, $ref_args) = @_;

	$class = ref($class) if ref $class;

	my $self = bless({}, $class);

	my $name              = $ref_args->{name};
	my $nb_args           = $ref_args->{nb_args};
	my $calc              = $ref_args->{calc};

	croak 'Name should be specified.'    unless defined $name;
	croak 'Nb args should be specified.' unless defined $nb_args;
	croak 'Calc should be specified.'    unless defined $calc;

	$self->{_NAME}             = $name;
	$self->{_NB_ARGS}          = $nb_args;
	$self->{_CALC_REF}         = $calc;

	$functions->{$name} = $self;
	return $self;
}

# static subs
sub initialize {
	Math::Function->_new({
		name    => 'ln',
		nb_args => 1,
		calc    => \&_ln,
		});

	Math::Function->_new({
		name    => 'sqrt',
		nb_args => 1,
		calc    => \&_sqrt,
		});

	Math::Function->_new({
		name    => 'exp',
		nb_args => 1,
		calc    => \&_exp,
		});

	Math::Function->_new({
		name    => 'log',
		nb_args => 1,
		calc    => \&_log,
		});
}

sub get_functions {
	my $class = shift;

	return %$functions;
}

sub get_nb_functions {
	my $class = shift;

	return scalar keys %$functions;
}


## accessors/mutators
sub name {
	my ($self, $name) = @_;

	if(defined $name) {
		$self->{_NAME} = $name;
	}
	return $self->{_NAME};
}

sub nb_args {
	my ($self, $nb_args) = @_;

	if(defined $nb_args) {
		$self->{_NB_ARGS} = $nb_args;
	}
	return $self->{_NB_ARGS};
}

sub calc {
	my ($self, $calc) = @_;

	if(defined $calc) {
		$self->{_CALC_REF} = $calc;
	}
	return $self->{_CALC_REF};
}

## class subs

sub compute {
	my ($self, @args) = @_;

	return $self->{_CALC_REF}(@args);
}

sub DESTROY {
	my $self = shift;
	my $name = $self->name();
	$functions->{$name} = undef if defined $name;
}

## functions subs
sub _log {
	log ($_[0]) / log(10);
}

sub _exp {
	exp $_[0];
}

sub _sqrt {
	sqrt $_[0];
}

sub _ln {
    log $_[0];
}
1;
__END__