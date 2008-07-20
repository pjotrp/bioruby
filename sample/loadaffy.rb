#!/usr/bin/env ruby
#
# loadaffy: Loads an Affymetrix CEL file and displays some data
#
#   Copyright (C) 2008 Pjotr Prins
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
#  $Id$
#

require 'bio'

include Bio

usage = <<USAGE

Usage: loadaffy.rb infiles

  Examples:

    ruby -Ilib loadaffy.rb GSM111111.CEL.gz 

USAGE

if ARGV.size == 0
  print usage
	exit 1
end

ARGV.each do | fn |
  array = Bio::Microarray::Affy.new(fn)
  print fn,"\n"
  (0..20).each do | i |
    print array.intensity(i),", "
  end
  array.close # optional
end


