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

      module XML
      end # XML

      # Definitition of a GEO family file - describing a series of microarrays
      class GEO_Family

        # Load the MINiML family file - assuming all related files are stored
        # in the same path
        def initialize xmlfn
          @path = File.dirname(xmlfn)
          @fn   = File.basename(xmlfn)
          $stderr.print "Loading #{@fn} from #{@path}\n" if $VERBOSE 
          @xml = XmlSimple.xml_in(xmlfn, { 'KeyAttr' => 'name' })
        end

        # Returns a Hash of sample information
        def each_sample
          @xml['Sample'].each do | sample |
            yield sample
          end
        end

        # Iterate sample accessions - returns GEO accession 
        def each_sample_acc
          each_sample do | sample |
            yield sample['iid']
          end
        end

        # Fetch the data points for sample +acc+ using +options+. Returns
        # data points as an array (by default ID and VALUE).
        #
        def each_row acc, options = {:columns=>["ID_REF", "VALUE"]}
          names = options[:columns]
          # ---- get the sample layout
          each_sample do | sample |
            if sample['iid'] == acc
              datafn = sample['Data-Table'][0]['External-Data'][0]['content'].strip
              # ---- find the columns
              positions = []
              sample['Data-Table'][0]['Column'].each do | column |
                if names.include? column['Name'][0]
                  positions.push column['position'].to_i-1
                end
              end
              # ---- read the data file and yield points
              File.open(@path+'/'+datafn).each_line do | line |
                fields = line.split(/\t/)
                yield positions.collect { | pos | fields[pos] }
              end
              break
            end
          end
        end
      end



    end # MINiML
  end # Microarray
end # Bio
        

