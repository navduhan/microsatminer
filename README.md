# MicroSatMiner

MicroSatMiner is a Perl-based tool for detecting Simple Sequence Repeats (SSRs) or microsatellites in DNA sequences. It provides efficient detection of mono-, di-, tri-, tetra-, penta-, and hexa-nucleotide repeats with customizable parameters.

## Features

- Detection of SSRs from mono- to hexa-nucleotide repeats
- Customizable minimum repeat length for each type
- Flexible motif length parameters
- Output in tab-delimited format for easy parsing
- Statistical summary of detected SSRs
- Memory-efficient processing of large sequence files
- Progress tracking for long-running analyses

## Installation

No installation is required. Simply clone the repository and ensure you have Perl installed on your system:

```bash
git clone https://github.com/navduhan/microsatminer.git
cd microsatminer
chmod +x MicroSatMiner.pl
```

### Requirements

- Perl 5.10 or higher
- Core Perl modules:
  - strict
  - warnings
  - Getopt::Long
  - File::Basename
  - Time::HiRes

## Usage

Basic usage:
```bash
./MicroSatMiner.pl -i <input_fasta_file> [options]
```

### Options

- `-i <file>`  : Input FASTA format file (required)
- `-min <int>` : Minimum length of repeat motif (default: 1)
- `-max <int>` : Maximum length of repeat motif (default: 6)
- `-t <int>`   : Minimum number of times a motif should repeat (default: 5)
- `-ml <int>`  : Minimum number of times a mono repeat should occur (default: 10)
- `-sp <str>`  : Output file prefix (default: MicroSatMiner_results)
- `-h, --help` : Show help message
- `-v`         : Show version information

### Example

```bash
./MicroSatMiner.pl -i example.fasta -min 2 -max 6 -t 6 -ml 12 -sp my_results
```

## Output Files

The program generates two output files:

1. `<prefix>.ssr.txt`: Tab-delimited file containing detected SSRs with the following columns:
   - ID: Sequence identifier
   - Seq_Length: Length of the sequence
   - Start: Start position of the SSR
   - End: End position of the SSR
   - Repeat_number: Number of times the motif repeats
   - Motif: The repeat motif
   - Type: Type of SSR (mono/di/tri/tetra/penta/hexa)

2. `<prefix>.ssr_statistics`: Summary statistics of detected SSRs including:
   - Distribution of different SSR types
   - Count of each SSR type

## Testing

To run the test suite:

```bash
cd tests
perl test_microsatminer.t
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Naveen Duhan (naveen.duhan@usu.edu)

## Citation

If you use MicroSatMiner in your research, please cite:

```
Duhan, N. (2024). MicroSatMiner: A Perl tool for efficient microsatellite detection.
GitHub repository: https://github.com/yourusername/microsatminer
``` 