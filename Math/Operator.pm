package Math::Operator;

use strict;
use warnings;
use Carp;

my $operators = {};


# constructor
sub _new {
	my ($class, $ref_args) = @_;

	$class = ref($class) if ref $class;

	my $self = bless ({}, $class);

	my $name              = $ref_args->{name};
	my $nb_args           = $ref_args->{nb_args};
	my $regex             = $ref_args->{regex};
	my $precedence        = $ref_args->{precedence};
	my $left_associative  = $ref_args->{left_associative};
	my $calc              = $ref_args->{calc};

	croak 'Name should be specified.'             unless defined $name;
	croak 'Nb args should be specified.'          unless defined $nb_args;
	croak 'Regex should be specified.'            unless defined $regex;
	croak 'Precedence should be specified.'       unless defined $precedence;
	croak 'Left associative should be specified.' unless defined $left_associative;
	croak 'Calc should be specified.'             unless defined $calc;

	
	$self->{_NAME}             = $name;
	$self->{_NB_ARGS}          = $nb_args;
	$self->{_REGEX}            = $regex;
	$self->{_PRECEDENCE}       = $precedence;
	$self->{_LEFT_ASSOCIATIVE} = $left_associative;
	$self->{_CALC_REF}         = $calc;

	$operators->{$name} = $self;
	return $self;
}

## static subs
sub initialize {
	Math::Operator->_new({
		name              => '+',
		nb_args           => 2,
		regex             => '[+]',
		precedence        => 12,
		left_associative  => 1,
		calc              => \&_add,
		});

	Math::Operator->_new({
		name              => '-',
		nb_args           => 2,
		regex             => '[-]',
		precedence        => 12,
		left_associative  => 1,
		calc              => \&_sub,
		});
	Math::Operator->_new({
		name => '*',
		nb_args => 2,
		regex  => '[*]',
		precedence => 13,
		left_associative  => 1,
		calc    => \&_mul,
		});

	Math::Operator->_new({
		name => '/',
		nb_args => 2,
		regex  => '[/]',
		precedence => 13,
		left_associative  => 1,
		calc    => \&_div,
		});

	Math::Operator->_new({
		name => '%',
		nb_args => 2,
		regex  => '[%]',
		precedence => 13,
		left_associative  => 1,
		calc    => \&_mod,
		});

	Math::Operator->_new({
		name => '^',
		nb_args => 2,
		regex  => '[\^]',
		precedence => 14,
		left_associative  => 0,
		calc    => \&_pow,
		});
}



sub get_operators {
	my $class = shift;

	return %$operators;
}

sub get_nb_operators {
	my $class = shift;

	return scalar keys %$operators;
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

sub regex {
	my ($self, $regex) = @_;

	if(defined $regex) {
		$self->{_REGEX} = $regex;
	}
	return $self->{_REGEX};
}

sub precedence {
	my ($self, $precedence) = @_;

	if(defined $precedence) {
		$self->{_PRECEDENCE} = $precedence;
	}
	return $self->{_PRECEDENCE};
}

sub left_associative {
	my ($self, $left_associative) = @_;

	if(defined $left_associative) {
		$self->{_LEFT_ASSOCIATIVE} = $left_associative;
	}
	return $self->{_LEFT_ASSOCIATIVE};
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
	$operators->{$name} = undef if defined $name;
}

## operators subs
sub _add {
    my ($op1, $op2) = @_;
    return $op1 + $op2;
}

sub _sub{
    my ($op1, $op2) = @_;
    return $op1 - $op2;
}

sub _mul{
    my ($op1, $op2) = @_;
    return $op1 * $op2;
}

sub _div{
    my ($op1, $op2) = @_;
    return $op1 / $op2;
}

sub _mod{
    my ($op1, $op2) = @_;
    return $op1 / $op2;
}

sub _pow{
    my ($op1, $op2) = @_;
    return $op1 ** $op2;
}

1;
__END__