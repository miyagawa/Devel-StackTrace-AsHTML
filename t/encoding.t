use strict;
use Test::More;
use Devel::StackTrace::AsHTML;

my $html;

sub foo {
    my $t = Devel::StackTrace->new;
    $html = $t->as_html;
}

foo("\x{30c6}");

like $html, qr/Error: &#12486;/;

done_testing;
