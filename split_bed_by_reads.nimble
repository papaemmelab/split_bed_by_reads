# Package

version       = "0.1.0"
author        = "Max Levine"
description   = "Split bed by bam read counts command-line tool"
license       = "MIT"
srcDir        = "src"
bin           = @["split_bed_by_reads"]


# Dependencies

requires "nim >= 0.19.0", "hts", "docopt"
