#
# = bio/db/microarray/miniml/miniml.rb - MINiML support (as used in NCBI GEO)
#
# Copyright::	Copyright (C) 2008, 2009 Pjotr Prins
# License::	The Ruby License
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

        def initialize geo_family, xml
          @geo_family = geo_family
          @xml = xml
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

        # Is this a two_color platform - 'educated' guess, at least
        # for Affymetrix
        #
        def two_color?
          return false if manufacturer=~/ffymetrix/
          return channels==2
        end

        # Yields a tabular row with the probe information from the GPL
        # platform description
        #
        #  m = Bio::Microarray::MINiML::GEO_Family.new(fn)
        #  m.each_probe do | probeinfo |
        #    p probeinfo['ID'], probeinfo['Sequence Type'],probeinfo['Transcript ID']
        #  end
        #
        def each_probe
          # ---- get the sample layout
          data_table = sane_struct(@data,'Data-Table')
          if data_table
            external_data = data_table['External-Data']
            datafn = external_data[0]['content'].strip
            # ---- find the columns
            columns = {}
            data_table['Column'].each do | column |
              name = column['Name'][0]
              columns[column['position']] = name
            end
            # ---- read the data file and yield points
            File.open(@geo_family.path+'/'+datafn).each_line do | line |
              fields = line.split(/\t/)
              result = {}
              columns.each do | pos, name |
                pos = pos.to_i - 1
                # p [pos, name, fields[pos]]
                result[name] = fields[pos]
              end
              yield result
            end
          end
        end

        # Return an array of probe IDs
        def ids
          result = []
          each_probe do | probe |
            raise 'Probename not defined at line #{result.size}' if probe['ID']==nil or probe['ID']==''
            result.push probe['ID']
          end
          result
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

        # Return the name of the ID field
        def field_id
          'ID_REF'
        end

        # Return the name of the field containing the raw value of the probe.
        # Unfortunately there is no clear standard of uploading values into
        # GEO. The 'VALUE' field can mean different things (like genotype with
        # SNP arrays, probeset value, probe value or even differential value).
        # It is important to read the family file definition as even within
        # datasets there may be differences. This method will try the fields in
        # +searchlist+ first. Next it will look for 'RAW_SIGNAL', 'MedianS' and
        # finally 'VALUE'. The field name belonging to the first match will be
        # returned. So if your dataset contains 'VALUE2' and 'STRANGE' try
        #  
        #   name = field_raw(['VALUE2','STRANGE'])
        #
        # which will pick up the name in that search order.
        #
        # When no match is made an exception is raised.
        #
        def field_raw searchlist=[]
          searchlist = [] if searchlist==nil
          searchlist += ['RAW_SIGNAL', 'MedianS', 'VALUE']
          names = field_names
          searchlist.each do | match |
            return match if names.include?(match)
          end
          raise TypeError("No match found")
        end

        # Return External-Data information
        def external_data
          sane_struct(data_table,'External-Data')
        end

        # Return External-Data filename
        def external_data_filename
          if external_data
            datafn = external_data['content'].strip
          end
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
          if external_data
            datafn = external_data_filename
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
  
      # Definition of a GEO family file - describing a series of microarrays
      # in MINiML format. The meta-data is stored in XML by NCBI GEO. Probes
      # are stored in table files.
      #
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
          Platform.new self, @xml
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
        

