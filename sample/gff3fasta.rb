#!/usr/bin/env ruby
#
# fastagrep: Writes GFF3 to FASTA using a filter, e.g. mrna
#
#   Copyright (C) 2010 Pjotr Prins
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#

require 'bio'

include Bio

usage = <<USAGE
gff3fasta outputs GFF3 contained FASTA records

Usage: gff3fasta.rb infile

Example:

  gff3fasta.rb ../test/data/gff/test.gff3
USAGE

if ARGV.size == 0
  print usage
	exit 1
end

ARGV.each do | fn |
  gff3 = Bio::GFF::GFF3.new(File.read(fn))
  # gff3.records.each do | rec |
  # end
  gff3.sequences.each do | item |
    # print item.to_fasta(item.entry_id, 70)
    print item.output(:fasta)
  end
end


