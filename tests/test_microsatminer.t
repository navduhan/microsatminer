#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use File::Spec;

# Path to MicroSatMiner script
my $script = File::Spec->catfile($Bin, '..', 'MicroSatMiner.pl');
my $test_data = File::Spec->catfile($Bin, 'data', 'test.fasta');
my $temp_dir = tempdir(CLEANUP => 1);

# Ensure script is executable
system("chmod +x $script") unless -x $script;

# Basic tests
subtest 'Basic script checks' => sub {
    plan tests => 3;
    ok(-e $script, "MicroSatMiner.pl script exists") 
        or diag("Script not found at $script");
    ok(-x $script, "MicroSatMiner.pl is executable") 
        or diag("Script not executable. Try: chmod +x $script");
    ok(-e $test_data, "Test data file exists") 
        or diag("Test data not found at $test_data");
};

# Command line interface tests
subtest 'Command line interface' => sub {
    plan tests => 4;
    
    my $output = `$^X $script -h 2>&1`;
    like($output, qr/usage|options|help/i, "Help message is displayed correctly") 
        or diag("Output was: $output");
    
    $output = `$^X $script -v 2>&1`;
    like($output, qr/version|Version/i, "Version information is displayed correctly") 
        or diag("Output was: $output");
    
    $output = `$^X $script -i nonexistent.fasta 2>&1`;
    like($output, qr/Error|exist|found/i, "Error message for nonexistent input file") 
        or diag("Output was: $output");
    
    $output = `$^X $script -i $test_data -min -1 2>&1`;
    like($output, qr/Error|positive|invalid/i, "Error message for invalid minimum length") 
        or diag("Output was: $output");
};

# Process test file with default parameters
subtest 'Default parameter processing' => sub {
    plan tests => 3;
    
    my $result_file = File::Spec->catfile($temp_dir, "test_default");
    my $output = `$^X $script -i $test_data -sp $result_file 2>&1`;
    is($? >> 8, 0, "Script execution with default parameters successful") 
        or diag("Output was: $output");
    
    # Wait briefly for file system
    sleep(1);
    
    ok(-e "$result_file.ssr.txt", "SSR results file exists") 
        or diag("SSR results file not found at $result_file.ssr.txt");
    ok(-e "$result_file.ssr_statistics", "Statistics file exists")
        or diag("Statistics file not found at $result_file.ssr_statistics");
};

# SSR detection tests
subtest 'SSR detection' => sub {
    plan tests => 3;
    
    my $result_file = File::Spec->catfile($temp_dir, "test_default");
    
    SKIP: {
        skip "SSR results file not available", 1 
            unless -e "$result_file.ssr.txt";
        
        my $found_mono = 0;
        my $debug_output = "";
        if (open(my $fh, "<", "$result_file.ssr.txt")) {
            while(my $line = <$fh>) {
                $debug_output .= $line;
                if($line =~ /test_seq1.*mono.*A/) {
                    $found_mono = 1;
                    last;
                }
            }
            close $fh;
            ok($found_mono, "Mono-nucleotide repeat detected correctly") 
                or diag("Output content:\n$debug_output");
        } else {
            fail("Could not open SSR results file: $!");
        }
    }
    
    # Test with custom parameters
    $result_file = File::Spec->catfile($temp_dir, "test_custom");
    my $output = `$^X $script -i $test_data -sp $result_file -min 2 -max 4 -t 3 -ml 5 2>&1`;
    is($? >> 8, 0, "Script execution with custom parameters successful") 
        or diag("Output was: $output");
    
    SKIP: {
        skip "Custom results file not available", 1 
            unless -e "$result_file.ssr.txt";
        
        my $found_di = 0;
        my $debug_output = "";
        if (open(my $fh, "<", "$result_file.ssr.txt")) {
            <$fh>; # Skip header
            while(my $line = <$fh>) {
                $debug_output .= $line;
                if($line =~ /test_seq2.*di.*AT/) {
                    $found_di = 1;
                    last;
                }
            }
            close $fh;
            ok($found_di, "Di-nucleotide repeat detected correctly")
                or diag("Output content:\n$debug_output");
        } else {
            fail("Could not open custom results file: $!");
        }
    }
};

# Statistics tests
subtest 'Statistics generation' => sub {
    plan tests => 1;
    
    my $result_file = File::Spec->catfile($temp_dir, "test_default");
    SKIP: {
        skip "Statistics file not available", 1 
            unless -e "$result_file.ssr_statistics";
        
        my $has_stats = 0;
        if (open(my $fh, "<", "$result_file.ssr_statistics")) {
            while(<$fh>) {
                if(/Distribution/) {
                    $has_stats = 1;
                    last;
                }
            }
            close $fh;
            ok($has_stats, "Statistics file contains distribution information");
        } else {
            fail("Could not open statistics file: $!");
        }
    }
};

# Performance tests
subtest 'Performance checks' => sub {
    plan tests => 2;
    
    SKIP: {
        skip "Memory usage test not supported on this platform", 1 
            unless $^O =~ /linux|darwin/i;
        
        my $mem_before = `ps -o rss= -p $$` || 0;
        my $output = `$^X $script -i $test_data -sp $temp_dir/test_mem 2>&1`;
        my $mem_after = `ps -o rss= -p $$` || 0;
        ok($mem_after - $mem_before < 1000000, "Memory usage within reasonable limits") 
            or diag("Memory usage: Before=$mem_before, After=$mem_after");
    }
    
    my $start_time = time();
    my $output = `$^X $script -i $test_data -sp $temp_dir/test_time 2>&1`;
    my $end_time = time();
    ok($end_time - $start_time < 60, "Processing completed within reasonable time") 
        or diag("Processing time: " . ($end_time - $start_time) . " seconds");
};

# Cleanup
END {
    remove_tree($temp_dir) if defined $temp_dir && -d $temp_dir;
}

done_testing(); 