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

require 'biolib_ruby_affyio'

module Bio

  class Microarray

    class Affy 

      attr_reader :celobject
      # Affymetrix microarray class represents one CEL file. Example:
      #
      #   array = Bio::Microarray::Affy.new(fn)
      #   array.intensity(10) # show 10th probe

      def initialize(celfilename)
        @celobject = Biolib_ruby_affyio.open_celfile(celfilename)
        ObjectSpace.define_finalizer(self,self.class.method(:finalize).to_proc)
      end

      # Close the affy celfile and clean up (it is not necessary to call this,
      # only if you are want to be ahead of the garbage collector
      def close
        Affy.finalize(self)
      end

      # Disable the object
      def disable
        @celobject = nil
      end

      def Affy.finalize(id)
        if id.celobject != nil
          Biolib_ruby_affyio.close_celfile(id.celobject)
          id.disable
        end
      end

      def intensity index
        Biolib_ruby_affyio.cel_intensity(@celobject,index) 
      end

    end

  end

end
