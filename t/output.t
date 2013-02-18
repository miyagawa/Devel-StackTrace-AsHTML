use strict;
use Test::More;
use Devel::StackTrace::AsHTML;

my $html;

sub foo {
    my $t = Devel::StackTrace->new;
    $html = $t->as_html;
}

sub bar { foo("bar") }
bar(2);

like $html, qr/match.*bar\(2\)/;
like $html, qr!t[\\/]output\.t line 8.*\n.*in main::foo!;

done_testing;
