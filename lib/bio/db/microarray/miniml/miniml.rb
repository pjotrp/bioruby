#
# = bio/db/microarray/miniml/miniml.rb - MINiML support (as used in NCBI GEO)
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#
# $Id$
#

# The MINiML module is in the development stage. This version reads the GEO
# family XML file, which can be downloaded through FTP, and parses values from
# the value tables for each sample. 
#
# See http://github.com/pjotrp/bioruby/wikis for more information
#
# Notes:
#
#   - xml-simple dependency (will change later to rexml)
#
# Pjotr Prins

require 'xmlsimple'

module Bio

  module Microarray

    module MINiML

      # Handling of Simple-XML structures - usually a Hash within an Array -
      # internal use only
      module Sanity

        # Return a valid and stripped value, or nil
        def sane_field data, fieldname
          data = data[0] if data.kind_of?(Array)
          return nil if data == nil 
          return nil if data[fieldname] == nil
          return nil if data[fieldname][0] == nil
          data[fieldname][0].strip
        end

        # Like sane_field, but always return a String
        def sane_field_s data, fieldname
          retval = sane_field data, fieldname
          retval='' if retval == nil
          retval
        end

        def sane_struct data, structname
          return nil if data == nil 
          data = data[0] if data.kind_of?(Array)
          return nil if data == nil 
          return nil if data[structname]==nil
          data[structname][0]
        end
      end

      # Represents a Platform definition (mostly for internal use)
      class Platform 

        include Sanity

        def initialize geo_family
          @xml = geo_family
          @data = @xml['Platform']
        end

        def manufacturer
          sane_field @data,'Manufacturer'
        end

        def technology
          sane_field @data,'Technology'
        end

        # Fetch the number of channels from the first sample
        def channels
          sample = @xml['Sample'][0]
          num = sane_field(sample,'Channel-Count')
          return 1 if num==nil
          num.to_i
        end

        # Is this a two_color platform - educated guess
        def two_color?
          return false if manufacturer=~/ffymetrix/
          return channels==2
        end
      end

      # Represents a Sample definition (mostly for internal use)
      class Sample

        include Sanity

        # pass a reference to GEO_Family Sample hash
        def initialize geo_family, sampledata
          @geo_family = geo_family
          @data = sampledata
        end

        # Return GEO accession
        def acc
          @data['iid']
        end

        def title
          sane_field @data, 'Title'
        end

        # Return number of rows
        def rows
          return external_data['rows'].to_i if external_data != nil
          0 
        end

        # return field names in an Array
        def field_names
          names = []
          if data_table
            data_table['Column'].each do | c |
              names.push sane_field(c,'Name')
            end
          end
          names
        end

        # Return External-Data information
        def external_data
          sane_struct(data_table,'External-Data')
        end

        # Yields a tabular row with the data points for sample using +options+.
        # Returns data points as an array (by default ID and VALUE). A value
        # column is returned as a Float. Example:
        #
        #  m = Bio::Microarray::MINiML::GEO_Family.new(fn)
        #  m.each_sample do | sample |
        #    sample.each_row() do | tablerow |
        #      rowname = data[0]
        #      rownames.add(data[0])
        #      matrix.push = data[1]
        #    end
        #  end
        #
        def each_row options = {:columns=>["ID_REF", "VALUE"]}
          names = options[:columns]
          value_position = nil
          # ---- get the sample layout
          sample = @data
          if external_data
            datafn = external_data['content'].strip
            # ---- find the columns
            positions = []
            data_table['Column'].each do | column |
              name = column['Name'][0]
              if names.include? column['Name'][0]
                value_position = positions.size if name == 'VALUE'
                positions.push column['position'].to_i-1
              end
            end
            # ---- read the data file and yield points
            File.open(@geo_family.path+'/'+datafn).each_line do | line |
              fields = line.split(/\t/)
              yield positions.collect { | pos | ( pos==value_position ? fields[pos].strip.to_f : fields[pos].strip ) }
            end
          end

        end

        protected
    
          def data_table
            sane_struct @data,'Data-Table'
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
          print "Loading #{@fn} from #{@path}\n" if $VERBOSE 
          @xml = XmlSimple.xml_in(xmlfn, { 'KeyAttr' => 'name' })
        end

        # Return the Platform object
        def platform
          Platform.new @xml
        end

        # Return the number of samples
        def samples
          @xml['Sample'].size
        end

        # Returns all Sample objects
        def each_sample
          @xml['Sample'].each do | sample |
            yield Sample.new(self,sample)
          end
        end

        # Iterate sample accessions - returns GEO accession 
        def each_sample_acc
          each_sample do | sample |
            yield sample.acc
          end
        end

      end



    end # MINiML
  end # Microarray
end # Bio
        

