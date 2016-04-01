# NAME

Devel::StackTrace::AsHTML - Displays stack trace in HTML

# SYNOPSIS

    use Devel::StackTrace::AsHTML;

    my $trace = Devel::StackTrace->new;
    my $html  = $trace->as_html;

# DESCRIPTION

Devel::StackTrace::AsHTML adds `as_html` method to [Devel::StackTrace](https://metacpan.org/pod/Devel::StackTrace) which
displays the stack trace in beautiful HTML, with code snippet context and
function parameters. If you call it on an instance of
[Devel::StackTrace::WithLexicals](https://metacpan.org/pod/Devel::StackTrace::WithLexicals), you even get to see the lexical variables
of each stack frame.

# AUTHOR

Tatsuhiko Miyagawa <miyagawa@bulknews.net>

Shawn M Moore

HTML generation code is ripped off from [CGI::ExceptionManager](https://metacpan.org/pod/CGI::ExceptionManager) written by Tokuhiro Matsuno and Kazuho Oku.

# COPYRIGHT

The following copyright notice applies to all the files provided in
this distribution, including binary files, unless explicitly noted
otherwise.

Copyright 2009-2013 Tatsuhiko Miyagawa

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[Devel::StackTrace](https://metacpan.org/pod/Devel::StackTrace) [Devel::StackTrace::WithLexicals](https://metacpan.org/pod/Devel::StackTrace::WithLexicals) [CGI::ExceptionManager](https://metacpan.org/pod/CGI::ExceptionManager)
