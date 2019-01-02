Nim Program to split bed files based on a maximum read count in each interval for a given bam file.

# Usage:

```
Split bed intervals by maximum read counts

Usage:
  split_bed_by_reads [options] <BED> <BAM> <OUT>

Arguments:
  <BED>     Input bed file
  <BAM>     Input bam file
  <OUT>     Output bed file

Options:
  -h --help                 Show this screen.
  -v --version              Show version.
  -t --threads <threads>    Number of BAM decompression threads [default: 4]
  -c --count <count>        Number of reads to split  [default: 1000000].
```

# Credit
* Max Levine [@mflevine](https://github.com/mflevine)
* [hts-nim-tools](https://github.com/brentp/hts-nim-tools) by Brent Pederson [@brentp](https://github.com/brentp)
