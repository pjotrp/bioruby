#
# = bio/db/microarray/miniml/miniml.rb - MINiML support (as used in NCBI GEO)
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#
# $Id$
#

# The MINiML module is in the development stage.
#
# Notes:
#
#   - xml-simple dependency
#   - handle verbosity ($VERBOSE switch?)
#
# Pjotr Prins

require 'xmlsimple'

module Bio

  module Microarray

    module MINiML

      # Represents a Sample definition (mostly for internal use)
      class Sample

        # pass a reference to GEO_Family Sample hash
        def initialize geo_family, sampledata
          @geo_family = geo_family
          @data = sampledata
        end

        # Fetch the data points for sample using +options+. Returns
        # data points as an array (by default ID and VALUE). A value
        # column is returned as a Float.
        #
        def each_row options = {:columns=>["ID_REF", "VALUE"]}
          names = options[:columns]
          value_position = nil
          # ---- get the sample layout
          sample = @data
          datafn = sample['Data-Table'][0]['External-Data'][0]['content'].strip
          # ---- find the columns
          positions = []
          sample['Data-Table'][0]['Column'].each do | column |
            name = column['Name'][0]
            if names.include? column['Name'][0]
              value_position = positions.size if name == 'VALUE'
              positions.push column['position'].to_i-1
            end
          end
          # ---- read the data file and yield points
          File.open(@geo_family.path+'/'+datafn).each_line do | line |
            fields = line.split(/\t/)
            yield positions.collect { | pos | ( pos==value_position ? fields[pos].to_f : fields[pos] ) }
          end
        end

      end
  
      # Definitition of a GEO family file - describing a series of microarrays
      class GEO_Family

        attr_reader :path
        # Load the MINiML family file - assuming all related files are stored
        # in the same path
        def initialize xmlfn
          @path = File.dirname(xmlfn)
          @fn   = File.basename(xmlfn)
          $stderr.print "Loading #{@fn} from #{@path}\n" if $VERBOSE 
          @xml = XmlSimple.xml_in(xmlfn, { 'KeyAttr' => 'name' })
        end

        # Returns a Sample object
        def each_sample
          @xml['Sample'].each do | sample |
            yield Sample.new(self,sample)
          end
        end

        # Iterate sample accessions - returns GEO accession 
        def each_sample_acc
          each_sample do | sample |
            yield sample['iid']
          end
        end

      end



    end # MINiML
  end # Microarray
end # Bio
        

