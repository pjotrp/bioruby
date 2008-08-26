#
# = bio/db/microarray/ncbi_geo/geo.rb - NCBI GEO support
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#
# $Id$
#

# The GEO module is in the development stage. The general idea is to fetch and cache
# XML files for GPL, GSE and GSM descriptors - and to access them.
#
# Notes:
#
#   - xml-simple dependency 
#   - CACHE path is environment variable 'BIORUBY_CACHE' or the current directory
#   - handle verbosity (Bioruby's $VERBOSE switch?)
#
# See http://github.com/pjotrp/bioruby/wikis for more information
#
# Pjotr Prins

require 'uri'
require 'net/http'
require 'xmlsimple'

module Bio

  module Microarray

    module GEO

      module XML

        # Factory method to create an appropriate class based on the accession (GPL, GSE, GSM)
        def XML::create acc
          if valid_accession?(acc)
            if acc =~ /^GPL/
              return GPL.new(acc)
            elsif acc =~ /^GSE/
              return GSE.new(acc)
            elsif acc =~ /^GSM/
              return GSM.new(acc)
            else
              raise "GEO::XML::Create can not create a class for #{acc}"
            end
          end
          nil
        end

        # Fetch an XML definition from the NCBI site
        def XML::fetch xmlfn, acc
          url = "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=#{acc}&form=xml&view=brief&retmode=xml" 
          r = Net::HTTP.get_response( URI.parse( url ) )
          f = File.new(xmlfn,'w')
          f.write(r.body)
          f.close
        end

        # Is this a valid GEO accession?
        def XML::valid_accession? acc = nil
          acc = @acc if not acc
          acc =~ /^(GSM|GSE|GPL)\d+$/
        end

        # Parse XML for GEO acc - caching the file if it does not exist
        # Returns a reference to the XML simple structure
        #
        def XML::parsexml acc
          if XML::valid_accession? acc
            cache = ENV['BIORUBY_CACHE']
            cache = '.' if not cache
            fn = cache+'/'+acc+'.xml'
            if !File.exist?(fn)
              XML::fetch(fn,acc)
            end
            $stderr.print "Parsing #{fn}\n" if $VERBOSE
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

        def valid_accession? 
          XML::valid_accession? @acc
        end

        def title
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
