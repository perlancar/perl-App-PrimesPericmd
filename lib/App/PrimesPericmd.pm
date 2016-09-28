package App::PrimesPericmd;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{primes} = {
    v => 1.1,
    summary => 'Generate primes (Perinci::CmdLine-based version)',
    description => <<'_',

This version of `primes` utility uses the wonderful <pm:Math::Prime::Util> and
supports bigints.

_
    args => {
        start => {
            schema => 'int*',
            req => 1,
            pos => 0,
        },
        stop => {
            schema => 'int*',
            pos => 1,
        },
        bigint => {
            summary => 'Turn on bigint support',
            schema => 'bool',
        },
    },
    examples => [
        {
            summary => 'Generate primes',
            src => '[[prog]]',
            src_plang => 'bash',
            'x.doc.show_result' => 0,
        },
        {
            summary => 'Generate primes that are larger than 1000',
            src => '[[prog]] 1000',
            src_plang => 'bash',
            'x.doc.show_result' => 0,
        },
        {
            summary => 'Generate primes between 1000 to 2000',
            src => '[[prog]] 1000 2000',
            src_plang => 'bash',
            'x.doc.max_result_lines' => 8,
        },
    ],
    links => [
        {url => 'prog:primes'},
        {url => 'prog:primes.pl'},
    ],
};
sub primes {
    require Math::Prime::Util;

    my %args = @_;

    my $start = $args{start} // 2;
    my $stop  = $args{stop};

    if (defined $stop) {
        my @res;
        if ($args{bigint}) {
            use bigint;
            my $n = $start-1;
            while (1) {
                $n = Math::Prime::Util::next_prime($n);
                if ($n <= $stop) {
                    push @res, $n;
                } else {
                    last;
                }
            }
        } else {
            # XXX how to avoid code duplicate?
            my $n = $start-1;
            while (1) {
                $n = Math::Prime::Util::next_prime($n);
                if ($n <= $stop) {
                    push @res, $n;
                } else {
                    last;
                }
            }
        }
        return [200, "OK", \@res];
    } else {
        # stream
        my $func;
        if ($args{bigint}) {
            use bigint;
            my $n = $start-1;
            $func = sub {
                $n = Math::Prime::Util::next_prime($n);
            };
        } else {
            # XXX how to avoid code duplicate?
            my $n = $start-1;
            $func = sub {
                $n = Math::Prime::Util::next_prime($n);
            };
        }
        return [200, "OK", $func, {stream=>1}];
    }
}

1;
# ABSTRACT:

=head1 DESCRIPTION

TODO: transparent bigint support (without having user specify `--bigint`).


=head1 SEE ALSO

L<Math::Prime::Util>
