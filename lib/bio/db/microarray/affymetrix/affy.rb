#
# = bio/db/affy.rb - Affymetrix microarray database classes
#
# Copyright::	Copyright (C) 2008
# 		Pjotr Prins
# License::	The Ruby License
#
# $Id$
#
# = About Bio::Microarray::Affy
#
# Affymetrix CEL file access using the Ben Bolstad's Biolib::Affyio package (part 
# of R Bioconductor). To use this feature you need to install biolib on your
# system.
#
# = References
#
# * ((<URL:http://biolib.open-bio.org/>))
# * http://bmbolstad.com/software/index.html
# * http://www.bioconductor.org/
#

require 'biolib/affyio'

module Bio

  module Microarray

    class Affy 

      attr_reader :cel, :probemap
      # The Affy microarray class represents one CEL file. Example:
      #
      #   array = Bio::Microarray::Affy.new(fn)
      #   array.intensity(10) # show 10th probe

      def initialize(filename, probemap=nil)
        @probemap = probemap
        raise "Affy file #{filename} does not exist!" if !File.exist?(filename)
        @cel = Biolib::Affyio.open_celfile(filename)
        ObjectSpace.define_finalizer(self,self.class.method(:finalize).to_proc)
      end

      # Close the affy celfile and clean up (it is not necessary to call this,
      # only if you are want to be ahead of the garbage collector
      def close
        Affy.finalize(self)
      end

      # Disable the object
      def disable
        @cel = nil
        @probemap = nil
      end

      def Affy.finalize(id)
        if id.cel != nil
          Biolib::Affyio.close_celfile(id.cel)
          id.disable
        end
      end

      # Set the probemap to an AffyProbemap object
      def probemap= pmap
        @probemap = pmap
      end

      # Print the intensity of the probe at +index+
      def probe index
        Biolib::Affyio.cel_intensity(@cel,index)
      end

      # Return an AffyProbeset object 
      def probeset number
        raise 'Undefined probemap!' if !@probemap
        AffyProbeset.new(self,number)
      end

    end

  end

end

if $0 == __FILE__

  print "Testing Affy...\n"

  $: << '../../../'

  require 'bio'
  require 'affyprobemap'
  require 'affyprobeset'

  datadir = ENV['HOME']+'/izip/svn/opensource/biolib/src/test/data/microarray/affy'
  celfn = datadir+'/test_binary.cel.gz'
  cdffn = '/tmp/test_cdf.dat'

  print `zcat #{datadir}/test_cdf.dat.gz > /tmp/test_cdf.dat`
  probemap = Bio::Microarray::AffyProbemap.new(cdffn)
  m        = Bio::Microarray::Affy.new(celfn,probemap)
  p m.probe(0)
  m.probemap = probemap # superfluous
  # hard wired
  probeset0 = probemap.probeset_info(0)
  p probeset0.pm_num
  # better
  probeset = m.probeset(11115)
  probeset.show

end
