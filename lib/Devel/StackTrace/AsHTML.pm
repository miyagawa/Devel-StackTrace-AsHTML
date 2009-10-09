package Devel::StackTrace::AsHTML;

use strict;
use 5.008_001;
our $VERSION = '0.03';

use Data::Dumper;
use Devel::StackTrace;
use Scalar::Util;

sub encode_html {
    my $str = shift;
    $str =~ s/&/&amp;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/"/&quot;/g;
    $str =~ s/'/&#39;/g;
    return $str;
}

sub Devel::StackTrace::as_html {
    __PACKAGE__->render(@_);
}

sub render {
    my $class = shift;
    my $trace = shift;
    my %opt   = @_;

    my $msg = encode_html($trace->frame(1)->args);
    my $out = qq{<!doctype html><head><title>Error: ${msg}</title>};

    $opt{style} ||= \<<STYLE;
a.toggle { color: #444 }
body { margin: 0; padding: 0; background: #fff; color: #000; }
h1 { margin: 0 0 .5em; padding: .25em .5em .1em 1.5em; border-bottom: thick solid #002; background: #444; color: #eee; font-size: x-large; }
p.head { margin: .5em 1em; }
li { font-size: small; }
pre.context { border: 1px solid #aaa; padding: 0.2em 0; background: #fff; color: #444; font-size: medium; }
pre .match { color: #000;background-color: #f99; font-weight: bold }
pre.vardump { margin:0 }
pre code strong { color: #000; background: #f88; }
.lexicals { display: none }
STYLE

    if (ref $opt{style}) {
        $out .= qq(<style type="text/css">${$opt{style}}</style>);
    } else {
        $out .= qq(<link rel="stylesheet" type="text/css" href=") . encode_html($opt{style}) . q(" />);
    }

    $out .= <<HEAD;
<script language="JavaScript" type="text/javascript">
function showLexicals(id) {
 var css = document.getElementById(id).style;
 css.display = css.display == 'block' ? 'none' : 'block'
}
</script>
</head>
<body>
<h1>Error trace</h1><p class="head">$msg</p><ol>
HEAD

    $trace->next_frame; # ignore the head
    my $i = 0;
    while (my $frame = $trace->next_frame) {
        $i++;
        $out .= join(
            '',
            '<li>',
            $frame->subroutine ? encode_html("in " . $frame->subroutine) : '',
            ' at ',
            $frame->filename ? encode_html($frame->filename) : '',
            ' line ',
            $frame->line,
            q(<pre class="context"><code>),
            _build_context($frame) || '',
            q(</code></pre>),
            $frame->can('lexicals') ? _build_lexicals($frame->lexicals, $i) : '',
            q(</li>),
        );
    }
    $out .= qq{</ol>};
    $out .= "</body></html>";

    $out;
}

sub _build_lexicals {
    my($lexicals, $ref) = @_;

    return '' unless keys %$lexicals;

    my $html = qq(<p><a class="toggle" href="javascript:showLexicals('lexicals-$ref')">Show lexical variables</a></p><pre class="lexicals" id="lexicals-$ref">);

    my $dumper = sub {
        my $d = Data::Dumper->new([ @_ ]);
        $d->Indent(1)->Terse(1)->Deparse(1);
        chomp(my $dump = $d->Dump);
        $dump;
    };

    # Don't use while each since Dumper confuses that
    for my $var (sort keys %$lexicals) {
        my $value = $lexicals->{$var};
        $value = $$value if ref $value eq 'SCALAR' or ref $value eq 'REF';
        my $dump = $dumper->($value);
        $dump =~ s/^\{(.*)\}$/($1)/s if $var =~ /^\%/;
        $dump =~ s/^\[(.*)\]$/($1)/s if $var =~ /^\@/;
        $html .= "my " . encode_html($var)  . " = " . encode_html($dump) . ";\n";
    }

    $html .= qq(</pre>);

    return $html;
}

sub _build_context {
    my $frame = shift;
    my $file    = $frame->filename;
    my $linenum = $frame->line;
    my $code;
    if (-f $file) {
        my $start = $linenum - 3;
        my $end   = $linenum + 3;
        $start = $start < 1 ? 1 : $start;
        open my $fh, '<', $file
            or die "cannot open $file:$!";
        my $cur_line = 0;
        while (my $line = <$fh>) {
            ++$cur_line;
            last if $cur_line > $end;
            next if $cur_line < $start;
            $line =~ s|\t|        |g;
            my @tag = $cur_line == $linenum
                ? (q{<strong class="match">}, '</strong>')
                    : ('', '');
            $code .= sprintf(
                '%s%5d: %s%s', $tag[0], $cur_line, encode_html($line),
                $tag[1],
            );
        }
        close $file;
    }
    return $code;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Devel::StackTrace::AsHTML - Displays stack trace in HTML

=head1 SYNOPSIS

  use Devel::StackTrace::AsHTML;

  my $trace = Devel::StackTrace->new;
  my $html  = $trace->as_html;

=head1 DESCRIPTION

Devel::StackTrace::AsHTML adds C<as_html> method to
L<Devel::StackTrace> which displays the stack trace in a beautiful
HTML, with code snippet context and even lexical variables, if you
call it on L<Devel::StackTrace::WithLexicals>.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

HTML generation code is ripped off from L<CGI::ExceptionManager> written by Tokuhiro Matsuno and Kazuho Oku.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Devel::StackTrace> L<Devel::StackTrace::WithLexicals> L<CGI::ExceptionManager>

=cut
