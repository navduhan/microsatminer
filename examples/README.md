# MicroSatMiner Examples

This directory contains example input and output files demonstrating the usage of MicroSatMiner.

## Files

- `example.fasta`: Sample FASTA file containing DNA sequences with various types of SSRs
  - Contains examples of mono-, di-, tri-, tetra-, penta-, and hexa-nucleotide repeats
  - Includes overlapping repeats for testing edge cases

- `example.ssr.txt`: Output file containing detected SSRs
  - Tab-delimited format
  - Shows all SSRs found in the input sequences
  - Includes position, length, and type information

- `example.ssr_statistics`: Statistical summary of detected SSRs
  - Shows distribution of different SSR types
  - Provides count for each type of repeat

## Running the Example

To process the example file:

```bash
./MicroSatMiner.pl -i examples/example.fasta -sp examples/example
```

This will generate the output files shown above.

## Understanding the Output

### SSR Results (example.ssr.txt)
The file contains tab-delimited columns:
- ID: Sequence identifier
- Seq_Length: Length of the sequence
- Start: Start position of the SSR
- End: End position of the SSR
- Repeat_number: Number of times the motif repeats
- Motif: The repeat motif
- Type: Type of SSR (mono/di/tri/tetra/penta/hexa)

### Statistics (example.ssr_statistics)
Shows the distribution of different types of SSRs found in the input sequences. 