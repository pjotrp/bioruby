#
# = bio/db/affy.rb - Affymetrix microarray database classes
#
# Copyright::	Copyright (C) 2008
# 		Pjotr Prins
# License::	The Ruby License
#
# $Id$
#
# = About Bio::Microarray::AffyProbeset
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


module Bio #:nodoc:

  module Microarray

    class AffyProbeset

      # Represents one probeset
      #
      # +affy+ is an Affy cel object
      # +number+ is the probeset number
      #
      def initialize(affy, number)
        @affy = affy
        @cel = affy.cel
        @cdf = affy.probemap.cdf
        @number = number
      end

      def info(index)
        Biolib::Affyio.cdf_probeset_info(@cdf,@number)
      end

      def name
        Biolib::Affyio.cdf_probeset_info(@cdf,@number).name
      end

      def pm_num
        Biolib::Affyio.cdf_probeset_info(@cdf,@number).pm_num
      end

      def mm_num
        Biolib::Affyio.cdf_probeset_info(@cdf,@number).mm_num
      end

      def each_pm
        (0..pm_num).each do | probe |
          yield Biolib::Affyio.cel_pm(@cel,@cdf,@number,probe)
        end
      end

      def each_mm
        (0..mm_num).each do | probe |
          yield Biolib::Affyio.cel_mm(@cel,@cdf,@number,probe)
        end
      end

      def show
        print name
        print "\n#{pm_num} PM: "
        each_pm do | intensity |
          print intensity,', '
        end

        print "\n#{mm_num} MM: "
        each_mm do | intensity |
          print intensity,', '
        end

      end
    end

  end
end
