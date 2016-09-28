package App::PrimesPericmd;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

BEGIN {
    # this is a temporary trick to let Data::Sah use Scalar::Util::Numeric::PP
    # (SUNPP) instead of Scalar::Util::Numeric (SUN). SUNPP allows bigints while
    # SUN currently does not.
    $ENV{DATA_SAH_CORE_OR_PP} = 1;
}

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
            pos => 0,
            default => 2,
        },
        stop => {
            schema => 'int*',
            pos => 1,
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
        {
            summary => 'Bigint support',
            src => '[[prog]] 18446744073709551616 18446744073709552000',
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
    my $bigint = do {
        # a method to check for the availability of 64bit integer, from:
        # http://www.perlmonks.org/?node_id=732199
        use bigint;
        if (eval { pack("Q", 65) }) {
            $start > 18446744073709551615;
        } else {
            $start > 4294967295;
        }
    };

    if (defined $stop) {
        my @res;
        if ($bigint) {
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

        # convert Math::BigInt objects into ints first, so the CLI formatter
        # detects it as simple aos
        for (@res) { $_ = $_->bstr if ref($_) eq 'Math::BigInt' }

        return [200, "OK", \@res];
    } else {
        # stream
        my $func;
        if ($bigint) {
            use bigint;
            my $n = $start-1;
            $func = sub {
                $n = Math::Prime::Util::next_prime($n);
                return ref($n) eq 'Math::BigInt' ? $n->bstr : $n;
            };
        } else {
            # XXX how to avoid code duplicate?
            my $n = $start-1;
            $func = sub {
                $n = Math::Prime::Util::next_prime($n);
                return ref($n) eq 'Math::BigInt' ? $n->bstr : $n;
            };
        }
        return [200, "OK", $func, {stream=>1}];
    }
}

1;
# ABSTRACT:

=head1 DESCRIPTION


=head1 prepend:SEE ALSO

L<Math::Prime::Util>
