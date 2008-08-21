# The GEO module is in the 'hacking' stage. The general idea is to fetch and cache
# XML files for GPL, GSE and GSM descriptors - and to access them.
#
# Notes:
#
#   - replace wget with Ruby HTML fetch
#   - xml-simple dependency
#   - naming conventions for methods required
#   - CACHE path should be configurable
#   - handle verbosity
#
# Pjotr Prins


module Bio

  module Microarray

    module GEO

      module XML
        
        # Fetch an XML definition from the NCBI site
        def XML::fetch xmlfn, acc
          $stderr.print `wget "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=#{acc}&form=xml&view=brief&retmode=xml" -O #{xmlfn}`
        end

        # Is this a GEO accession?
        def XML::isGEO? acc = nil
          acc = @acc if not acc
          acc =~ /^(GSM|GSE|GPL)\d+$/
        end

        # Parse XML for GEO acc - caching the file if it does not exist
        # Returns a reference to the XML simple structure
        #
        def XML::parsexml acc
          if XML::isGEO? acc
            cache = ENV['BIORUBY_CACHE']
            cache = '.' if not cache
            fn = cache+'/'+acc+'.xml'
            if !File.exist?(fn)
              XML::fetch(fn,acc)
            end
            $stderr.print "Reading #{fn}\n"
            return XmlSimple.xml_in(fn, { 'KeyAttr' => 'name' })
          end
          nil
        end

      end

      class GPL
        include XML

        def initialize platform
          @xml = XML::parsexml platform
          @acc = platform
        end

        def name
          if @xml
            @xml['Platform'][0]['Title'][0].strip
          else
            @acc
          end
        end

        def organism
          @xml['Platform'][0]['Organism'][0].strip if @xml
        end

      end

      class GSE
        include XML

        def initialize project
          @xml = XML::parsexml project
          @acc = project
        end

        def title
          if @xml
            @xml['Series'][0]['Title'][0].strip 
          else
            @acc
          end
        end

      end

      class GSM
        def initialize array
          @xml = XML::parsexml array
          @acc = array
        end

        def title
          if @xml
            @gsm['Sample'][0]['Title'][0].strip
          else
            @acc
          end
        end
      end

    end # GEO
  end # Microarray
end # Bio
