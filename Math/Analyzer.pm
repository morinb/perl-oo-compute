package Math::Analyzer;

use strict;
use warnings;
use Carp;
use Scalar::Util 'looks_like_number';

use Math::Operator;
use Math::Function;

my %operators;
my %functions;

sub new {
	my $class = shift;
	my $ref_args = shift;

	$class = ref $class if ref $class;
	my $self = bless {}, $class;

	my $debug = $ref_args->{debug};

	unless (defined $debug) {
		$self->{_DEBUG} = 0;
	}

	$self->{_DEBUG} = $debug;

	Math::Operator->initialize;
	%operators = Math::Operator->get_operators;

	Math::Function->initialize;
	%functions = Math::Function->get_functions;

	$self;
}

sub debug {
	my ($self, $debug) = @_;

	if(defined $debug) {
		$self->{_DEBUG} = $debug;
	}

	return $self->{_DEBUG};
}

sub to_RPN {
	my ($self, $formula, $map_ref) = @_;

	$self->_log("to_RPN called");

	my %var = %$map_ref;

	$formula = $self->_format_expression($formula);

	my @stack = ();
	my @queue = ();

	my @tokens = split(/ /, $formula);

	$self->_analyze(\@tokens, \@queue, \@stack, \%var);
}

sub _format_expression {
	my $self = shift;
	my $expr = shift;

	$self->_log("formatting expression...");

	$expr =~ s/\(/ \( /g;
	$self->_log($expr);
	$expr =~ s/\)/ \) /g;
	$self->_log($expr);
	$expr =~ s/,/ , /g;
	$self->_log($expr);

	for my $op (keys %operators) {
		my $regex = $operators{$op}->regex(); 
		$expr =~ s/$regex/ $op /g;
	$self->_log($expr);
	}

	$expr =~ s/\s+/ /g;
	$self->_log($expr);

	#handle unary -
	$expr =~ s/^(\s*-\s*)/0$1/g;
	$self->_log($expr);
	$expr =~ s/\((\s*-\s*)/\( 0$1/g;
	$self->_log($expr);

	$expr;
}


sub _analyze {
	my ($self, $token_ref, $queue_ref, $stack_ref, $var_ref) = @_;
    
    my @tokens = @$token_ref;
    my @queue  = @$queue_ref;
    my @stack  = @$stack_ref;
    my %var    = %$var_ref;

    foreach my $token (@tokens) {
        $self->_log("\nTreatment of token '$token'.");
        if (&looks_like_number($token)) {
            $self->_log("$token is a number. Adding it to the queue.");
            push @queue, $token;
            next;
        } elsif (&_isVariable($token, $var_ref)) {
            $self->_log("$token is a variable. Adding its value if defined to the queue.");
            if(defined $var{$token}) {
                my $val = $var{$token};
                $self->_log("Replacing variable $token by its value $val.");
                push @queue, $val;
            } else {
                push @queue, $token;
            }
            next;
        } elsif (&_isOperator($token)) {
            $self->_log("Token $token is an operator.");
            
            my $peek = $stack[$#stack];
            if (defined $peek) {
                if (&_isOperator($peek)) {
                    # peek stack
                    
                    my $op1 = $operators{$token};
                    my $op2 = $operators{$peek};
                    
                    #print Dumper($op1);
                    #print "$op1{$PRECEDENCE} : $op2{$PRECEDENCE}\n";
                    if (($op1->precedence <= $op2->precedence && $op1->left_associative)
                     || ($op1->precedence < $op2->precedence && !$op1->left_associative)) {
                        $self->_log("$token priority is <= $peek priority and $token is left-associative.") if $op1->left_associative;
                        $self->_log("$token priority is <= $peek priority and $token is right-associative.") if !$op1->left_associative;
                        $self->_log("Popping $peek from the stack, and push it to the queue.");
                        
                        push @queue, (pop @stack);
                    } else {
                        if ($op1->precedence > $op2->precedence) {
                            $self->_log("$token priority is > $peek priority.");
                        }
                    }
                }
            }
            $self->_log("Pushing $token onto the stack.");
            push @stack, $token;
            next; # verifier si necessaire, n'y est pas en java. 
        } elsif (&_isFunction($token)) {
            $self->_log("$token is a function. Pushing it onto the stack.");
            push @stack, $token;
            next;
        } elsif (&_isFunctionArgSeparator($token)) {
            $self->_log("$token is a function arg separator.");
            
            while ('(' ne $stack[$#stack]) {
                my $pop = pop @stack;
                $self->_log("Pop $pop from stack, adding it to the queue.");
                push @queue, $pop;
                if( @stack == 0) {
                    croak 'Parenthesis mismatch.';
                }
            }
            next;
        } elsif ('(' eq $token) {
            $self->_log("Pushing $token onto the stack;");
            push @stack, $token;
            next;
        } elsif (')' eq $token) {
            $self->_log("until ( is found on the stack, pop token from the stack to the queue.");
            
            while ('(' ne $stack[$#stack]) {
                my $pop = pop @stack;
                $self->_log("\tAdding $pop to the queue.");
                push @queue, $pop;
            }
            $self->_log("( found. Dismiss from the stack.");
            pop @stack;
            
			if(@stack > 0 ) {
				if (&_isFunction($stack[$#stack])) {
					my $peek  = $stack[$#stack];
					$self->_log("$peek is a function, pop it from the stack to the queue.");
					push @queue, (pop @stack);
				}
			}
        } else {
            $self->_log("$token unknown. Maybe a variable ?. Added to the queue.");
            push @queue, $token;
        }
        next;
    }
    
    $self->_log("No more token to read.");
    while(@stack != 0) { 
        if( '(' eq $stack[$#stack]) {
            croak "Parenthesis mismatch.";
        }
        my $pop = pop @stack;
        $self->_log("Popping $pop from the stack to the queue.");
        push @queue, $pop;
    }
    
    my $result = join ' ', @queue;
	$result =~ s/^\s+//;
	$result =~ s/\s+$//;
    $self->_log("$result");
    return $result;
}

sub compute {
	my ($self, $expr, $map_ref) = @_;

	$expr = $self->to_RPN($expr, $map_ref);

	my @tokens = split(' ', $expr);

	my @stack = ();

    foreach my $token (@tokens) {
        if (&_isFunction($token)) {
            $self->_log("$token is a function. Computing...");
            my $nb_args = $functions{$token}->nb_args();
            my @args = ();
            for(0..$nb_args-1) {
                push @args, pop @stack;
            }
            
            @args = reverse @args;
        
            my $result = $functions{$token}->calc()->(@args);
            $self->_log("$token(@args)=$result");
            push @stack, $result;
        } elsif (&_isOperator($token)) {
            $self->_log("$token is an operator. Computing...");
            
            my $nb_args = $operators{$token}->nb_args();
            my @args = ();
            for(0..$nb_args-1) {
                push @args, pop @stack;
            }
            @args = reverse @args;
            my $result = $operators{$token}->calc()->(@args);
            $self->_log("$token(@args)=$result");
            push @stack, $result;
        } else {
            $self->_log("Push $token onto the stack.");
            push @stack, $token;
        }
    }
    
    if(@stack != 1) { # only the final result should be on the stack
        confess "Some tokens are still on the stack, though all the formula has been analyzed.";
    }
    
    return pop @stack;

}







sub _log {
	my $self = shift;
	my $text = shift;

	my $debug = $self->debug();
	
    print $text."\n" if $debug;
}

sub _isNumber {
    &looks_like_number($_[0]);
}

sub _isVariable {
    my ($token, $map_ref) = @_;
    $map_ref->{$token};
}

sub _isOperator {
    defined $operators{$_[0]};
}

sub _isFunction {
    defined $functions{$_[0]};
}

sub _isFunctionArgSeparator {
    ',' eq $_[0];
}



1;
__END__