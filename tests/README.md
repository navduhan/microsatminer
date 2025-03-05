# MicroSatMiner Tests

This directory contains the test suite for MicroSatMiner. The tests verify the functionality, robustness, and performance of the SSR prediction tool.

## Test Structure

- `test_microsatminer.t`: Main test script
- `data/`: Directory containing test data
  - `test.fasta`: Sample FASTA file with known SSRs

## Test Coverage

The test suite covers:

1. Basic Functionality
   - Script existence and permissions
   - Help and version information
   - Input validation
   - Parameter validation

2. SSR Detection
   - Mono-nucleotide repeats
   - Di-nucleotide repeats
   - Tri-nucleotide repeats
   - Tetra-nucleotide repeats
   - Penta-nucleotide repeats
   - Hexa-nucleotide repeats
   - Overlapping repeats

3. Output Validation
   - Results file format
   - Statistics file format
   - Correct SSR identification

4. Performance
   - Memory usage
   - Processing time
   - Resource management

## Requirements

- Perl 5.x or higher
- Test::More module
- File::Temp module
- File::Path module

## Running Tests

To run all tests:
```bash
cd tests
perl test_microsatminer.t
```

Expected output will show test progress and results:
```
ok 1 - MicroSatMiner.pl script exists
ok 2 - MicroSatMiner.pl is executable
...
All tests successful.
Files=1, Tests=15, <time> wallclock secs
Result: PASS
```

## Adding New Tests

When adding new tests:
1. Add test data to `data/` directory if needed
2. Add test cases to `test_microsatminer.t`
3. Update the test count in the plan
4. Document new tests in this README

## Troubleshooting

If tests fail:
1. Check if all required modules are installed
2. Verify test data file permissions
3. Check system resources (memory, disk space)
4. Review error messages for specific test failures 