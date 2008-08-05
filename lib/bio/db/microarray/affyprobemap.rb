
module Bio #:nodoc:

  module Microarray

    class AffyProbemap

      attr_reader :cdf
      # Read the probemap from an Affy CDF file
      #
      def initialize filename
        raise "Affy CDF file #{filename} does not exist!" if !File.exist?(filename)
        @cdf = Biolib::Affyio.open_cdffile(filename)
        ObjectSpace.define_finalizer(self,self.class.method(:finalize).to_proc)
      end

      # Close the affy cdffile and clean up (it is not necessary to call this,
      # only if you are want to be ahead of the garbage collector
      def close
        AffyProbemap.finalize(self)
      end

      # Disable the object
      def disable
        @cdf = nil
      end

      def AffyProbemap.finalize(id)
        if id.cdf != nil
          Biolib::Affyio.close_cdffile(id.cdf)
          id.disable
        end
      end

      def probeset_info index
        Biolib::Affyio.cdf_probeset_info(@cdf,index)
      end
    end

  end
end
