use strict;
use warnings;

my $file = './input.txt';
open my $info, $file or die "Could not open $file: $!";

our @terrain = ();
while( my $line = <$info>)  {
    push(@terrain, $line)
}

close $info;

our @currentStart = (0, 0);
our @currentEnd = (0, 0);
our $maxHeight = 0;
our $maxWidth = 0;

our @r = (0..((scalar @terrain)-1));
for my $i (@r) {
    $maxHeight += 1;
    my $arraylen = length($terrain[$i]) - 1;
    $maxWidth = $arraylen;
    my @t = (0..($arraylen));
    foreach my $j (@t) {
        my $curr = substr($terrain[$i], $j, 1);
        if ($curr eq 'S') {
            @currentStart = ($i, $j);
        } elsif ($curr eq 'E') {
            @currentEnd = ($i, $j);
        }
    }
}

sub getHeight {
    my ($char) = @_;
    if ($char eq 'S') { 
        return ord('a');
    } elsif ($char eq 'E') {
        return ord('z');
    } else {
        return ord($char);
    }
}

sub findAdj {
    my ($loc) = @_;
    my @xy = split(',', $loc);
    my $y = $xy[0];
    my $x = $xy[1];
    my @validAdj = ();
    #y, x
    my $curr_height = getHeight(substr($terrain[$y], $x, 1));
    my @offsets = ([1, 0], [0, 1], [-1, 0], [0, -1]);
    foreach my $o (@offsets) {
        my $new_y = $y + @$o[0];
        my $new_x = $x + @$o[1];
        if ($new_y >= 0 && $new_x >= 0 && $new_y < $maxHeight && $new_x <= $maxWidth) {
            my $height = getHeight(substr($terrain[$new_y], $new_x, 1));
            if (($height - $curr_height) <= 1) {
                push(@validAdj, "$new_y,$new_x");
            }
        }
    }
    return \@validAdj;
}

sub findEnd {
    my $curStartStr = "$currentStart[0],$currentStart[1]";
    my $curEndStr = "$currentEnd[0],$currentEnd[1]";
    my @queue = ($curStartStr);
    my %visited = ();

    my %previous = ();

    my %distance = ();
    $distance{$curStartStr} = 0;

    while ((scalar @queue) > 0) {
        @queue = sort { $distance{$a} <=> $distance{$b} } @queue;
        my $p = shift @queue;
        if (exists $visited{$p}) {
            next;
        }
        $visited{$p} = 1;
        if ($p eq $curEndStr) {
            return $distance{$p};
        }
        my $adjRef = findAdj($p);
        my @adj = @$adjRef;
        foreach my $e (@adj) {
            $previous{$e} = $p;
            $distance{$e} = $distance{$p} + 1;
            push(@queue, $e);
        }
    }
    return -1;
}

sub findShortest {
    my $smallest = "inf";
    for my $i (@r) {
        my $arraylen = length($terrain[$i]) - 1;
        my @t = (0..($arraylen));
        foreach my $j (@t) {
            my $curr = substr($terrain[$i], $j, 1);
            if ($curr eq "a") {
                @currentStart = ($i, $j);
                my $pathLength = findEnd();
                if ($pathLength < 0) {
                    next;
                }
                if ($pathLength < $smallest) {
                    $smallest = $pathLength;
                }
            }
        }
    }
    return $smallest;
}

my $paths = findEnd();
print "Solution 1: $paths\n";
my $shortest = findShortest();
print "Solution 2: $shortest\n";
