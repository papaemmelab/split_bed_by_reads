Nim Program to split bed files based on a maximum read count in each interval for a given bam file.

# Installation:

Install nim and run as a nim script

```
curl https://nim-lang.org/choosenim/init.sh -sSf|sed "s/need_tty=yes/need_tty=no/g" | sh
export PATH=$HOME/.nimble/bin:$PATH

export PATH=${OPT_DIR}/.nimble/bin:$PATH
nimble install -y https://github.com/papaemmelab/split_bed_by_reads --nimbleDir:${OPT_DIR}/.nimble
```

Download the binaries:

```
wget -O ${BIN_DIR}/split_bed_by_reads https://github.com/papaemmelab/split_bed_by_reads/releases/download/0.1.0/split_bed_by_reads && \
chmod +x ${BIN_DIR}/split_bed_by_reads
export PATH=${BIN_DIR}:$PATH
```

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
