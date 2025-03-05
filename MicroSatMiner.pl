#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Time::HiRes qw(time);

# Version information
our $VERSION = "1.1";
our $PROGRAM = "MicroSatMiner";

# Default parameters
my %opts = (
    'min' => 1,
    'max' => 6,
    't'   => 5,
    'ml'  => 10,
    'sp'  => 'MicroSatMiner_results'
);

# Get command line options
GetOptions(
    \%opts,
    "i=s",
    "min=s",
    "max=s",
    "t=s",
    "sp=s",
    "ml=s",
    "help|h",
    "version|v"
) or die usage();

# Show help or version if requested
if (defined $opts{help} || !defined $opts{i}) {
    print usage();
    exit(0);
}

if (defined $opts{version}) {
    print "$PROGRAM version $VERSION\n";
    exit(0);
}

# Validate input parameters
die "Error: Input file '$opts{i}' does not exist!\n" unless -e $opts{i};
die "Error: Input file '$opts{i}' is empty!\n" unless -s $opts{i};

# Validate numeric parameters
for my $param (qw(min max t ml)) {
    die "Error: Parameter '$param' must be a positive integer!\n"
        unless $opts{$param} =~ /^\d+$/ && $opts{$param} > 0;
}

die "Error: Maximum motif length must be greater than minimum motif length!\n"
    if $opts{max} < $opts{min};

# Extract parameters
my ($seq, $min_motif, $max_motif, $times, $out, $ml) = 
    @opts{qw(i min max t sp ml)};

# Create output files
my $ssr_file = "$out.ssr.txt";
my $stats_file = "$out.ssr_statistics";

# Print program header and parameters
print_header();
print_parameters();

# Initialize variables for SSR detection
my ($id, $seq_len, $refseq, $refseq_sub) = ("", 0, "", "");
my ($pos, $start, $end, $count) = (0, 0, 0, 0);
my ($repeat_len, $repeat, @locus, $len, $type) = (0, "", (), 0, "");
$times = $times - 1;

# Process input file and detect SSRs
open(my $in_fh, "<", $seq) or die "Cannot open $seq: $!\n";
open(my $out_fh, ">", $ssr_file) or die "Cannot create $ssr_file: $!\n";

print $out_fh "ID\tSeq_Length\tStart\tEnd\tRepeat_number\tMotif\tType\n";

my $seq_count = 0;
my $start_time = time();

while (my $line = <$in_fh>) {
    chomp $line;
    
    if ($line =~ /^>(.*)/) {
        $seq_count++;
        print "Processing sequence $seq_count...\r" if $seq_count % 100 == 0;
        
        # Process previous sequence's SSRs
        if (@locus) {
            for my $repeat (@locus) {
                print $out_fh "$repeat\n" if length $repeat;
            }
        }
        
        # Reset for new sequence
        $id = $1;  # Use the sequence identifier without '>'
        ($pos, $refseq_sub, $refseq, $start, $end, $count) = (0, "", "", 0, 0, 0);
        @locus = ();
        $len = 0;
        
    } else {
        $line =~ s/[0-9\n\s]//g;
        $len += length $line;
        $refseq = $refseq_sub . $line;
        $count++;
        $seq_len = length $refseq;
        
        # Search for SSRs
        while ($refseq =~ /([ACGT]{$min_motif,$max_motif}?)\1{$times,}/gix) {
            my $motif = uc $1;
            my $repeat_len = length $motif;
            my $red_motif = int($repeat_len/2) + 1;
            $red_motif = 1 if $red_motif <= 1;
            
            my $start = $-[0] + 1;
            my $end = $+[0];
            
            unless ($motif =~ /^([ACGT]{1,$red_motif})\1+$/ix) {
                my $t_rep = ($end - $start + 1)/$repeat_len;
                $start += $pos;
                $end += $pos;
                
                my $ssr_type = length($motif) == 1 ? "mono" :
                              length($motif) == 2 ? "di" :
                              length($motif) == 3 ? "tri" :
                              length($motif) == 4 ? "tetra" :
                              length($motif) == 5 ? "penta" : "hexa";
                
                # Special handling for mono-nucleotide repeats
                if ($ssr_type eq "mono") {
                    next unless ($end - $start + 1) >= $ml;  # Skip if doesn't meet minimum length
                }
                
                push @locus, join("\t", $id, $len, $start, $end, $t_rep, $motif, $ssr_type);
            }
        }
        
        # Prepare for next iteration
        my $reconsider_len = 20;
        $pos += $seq_len - $reconsider_len + 1;
        $refseq_sub = substr($refseq, $seq_len - $reconsider_len + 1, $reconsider_len - 1);
    }
}

# Process last sequence
if (@locus) {
    for my $repeat (@locus) {
        print $out_fh "$repeat\n" if length $repeat;
    }
}

close $in_fh;
close $out_fh;

# Generate statistics
open(my $stats_fh, ">", $stats_file) or die "Cannot create $stats_file: $!\n";

print $stats_fh "Distribution of SSR types:\n";
print $stats_fh "Type\tCount\n";

my %type_counts;
open($out_fh, "<", $ssr_file) or die "Cannot open $ssr_file: $!\n";
<$out_fh>; # Skip header
while (my $line = <$out_fh>) {
    chomp $line;
    my @fields = split("\t", $line);
    my $type = $fields[6] || "unknown";  # Use the type field from the output
    $type_counts{$type}++;
}
close $out_fh;

for my $type (sort keys %type_counts) {
    print $stats_fh "$type\t$type_counts{$type}\n";
}

close $stats_fh;

my $elapsed = time() - $start_time;
printf "\nProcessed %d sequences in %.2f seconds\n", $seq_count, $elapsed;
print "\nResults are available in:\n";
print "  SSR results: $ssr_file\n";
print "  Statistics: $stats_file\n";

exit(0);

sub usage {
    return <<EOF;
Usage: $0 -i <input_file> [options]

Required:
    -i  <file>    Input FASTA format file

Optional:
    -min <int>    Minimum length of repeat motif (default: 1)
    -max <int>    Maximum length of repeat motif (default: 6)
    -t   <int>    Minimum number of times a motif should repeat (default: 5)
    -ml  <int>    Minimum number of times a mono repeat should occur (default: 10)
    -sp  <str>    Output file prefix (default: MicroSatMiner_results)
    -h, --help    Show this help message
    -v, --version Show version information

Example:
    $0 -i example.fasta -min 2 -max 6 -t 6 -ml 12 -sp my_results
EOF
}

sub print_header {
    print "\n" . "=" x 60 . "\n";
    print "Welcome to $PROGRAM version $VERSION\n\n";
    print "Author:  Naveen Duhan\n";
    print "Email:   naveen.duhan\@usu.edu\n";
    print "Date:    ", scalar localtime, "\n";
    print "=" x 60 . "\n\n";
}

sub print_parameters {
    print "Analysis parameters:\n";
    print "  Input file: $seq\n";
    print "  Minimum motif length: $min_motif\n";
    print "  Maximum motif length: $max_motif\n";
    print "  Minimum mono repeat occurrences: $ml\n";
    print "  Minimum repeat times: ", $times + 1, "\n\n";
    print "Processing sequences...\n";
}

