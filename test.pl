use strict;
use Carp;
use Math::Analyzer;



use Data::Dumper;

my $analyzer = new Math::Analyzer({debug=>0});



my %map = ();
$map{"m"} = 3;
$map{"g"} = 4;

print "sqrt((1/4)*(m*g)^2) + log(10) - exp(0) = ", $analyzer->compute("sqrt((1/4)*(m*g)^2) + log(10) - exp(0)", \%map),"\n";
for my $key (keys %map) {
	print "with $key = $map{$key}\n";
}

