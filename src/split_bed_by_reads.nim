let doc = """
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
"""

import strutils
import docopt
import hts
import times,os
import parsecsv
import tables
import algorithm
import sequtils

type
  region_t = ref object
    chrom: string
    start: int
    stop: int
    name: string
    count: int

# from https://github.com/brentp/hts-nim-tools
proc bed_line_to_region(line: string): region_t =
  var
   cse = line.strip().split('\t', 5)

  if len(cse) < 3:
    stderr.write_line("skipping bad bed line:", line.strip())
    return nil
  var
    s = parse_int(cse[1])
    e = parse_int(cse[2])
    reg = region_t(chrom: cse[0], start: s, stop: e, count:0)
  if len(cse) > 3:
   reg.name = cse[3]
  return reg

# from https://github.com/brentp/hts-nim-tools
proc bed_to_table(bed: string): TableRef[string, seq[region_t]] =
  var bed_regions = newTable[string, seq[region_t]]()
  var hf = hts.hts_open(cstring(bed), "r")
  var kstr: hts.kstring_t
  kstr.l = 0
  kstr.m = 0
  kstr.s = nil
  while hts_getline(hf, cint(10), addr kstr) > 0:
    if ($kstr.s).startswith("track "):
      continue
    if $kstr.s[0] == "#":
      continue
    var v = bed_line_to_region($kstr.s)
    if v == nil: continue
    discard bed_regions.hasKeyOrPut(v.chrom, new_seq[region_t]())
    bed_regions[v.chrom].add(v)

  # since it is read into mem, can also well sort.
  for chrom, ivs in bed_regions.mpairs:
    sort(ivs, proc (a, b: region_t): int = a.start - b.start)

  hts.free(kstr.s)
  return bed_regions

proc main() =
  let args = docopt(doc, version = "0.1.0")
  echo "BED: ", $args["<BED>"]
  echo "BAM: ", $args["<BAM>"]
  echo "OUT: ", $args["<OUT>"]
  echo "Count: ", $args["--count"], " reads"
  echo ""

  var
      bam: Bam
      count = 0
      start: int64 = 0
  let
    time = now()
    regions = bed_to_table($args["<BED>"])
    split = parseInt($args["--count"])
    out_bed = open($args["<OUT>"], fmWrite)
    threads = parseInt($args["--threads"])
  open(bam, $args["<BAM>"], threads=threads, index=true)

  for target in targets(bam.hdr):
      var chrom = target.name
      if not regions.contains(chrom) or regions[chrom].len == 0:
          continue
      for region in regions[chrom]:
          start = region.start
          for record in bam.query(region.chrom,region.start,region.stop):
              inc(count)
              if count mod split == 0:
                  if record.start > start: # if ending on high coverage position
                    echo region.chrom,":",start,"-",record.start," ",count
                    out_bed.writeLine(region.chrom & "\t" & $start & "\t" & $record.start & "\t" & $count)
                  start = record.start + 1
                  count = 0
          echo region.chrom,":",start,"-",region.stop," ",count
          out_bed.writeLine(region.chrom & "\t" & $start & "\t" & $region.stop & "\t" & $count)
          count = 0
      echo "Chr ", chrom, ":", now() - time
  echo now() - time
  close(bam)
  close(out_bed)

when isMainModule:
  main()
