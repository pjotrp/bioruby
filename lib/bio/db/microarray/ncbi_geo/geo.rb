#
# = bio/db/microarray/ncbi_geo/geo.rb - NCBI GEO support
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#
# $Id$
#

# The GEO module is in the development stage. The general idea is to fetch and cache
# XML files for GPL, GSE and GSM descriptors - and to access them. For examples you
# can also see the unit tests in test/unit/bio/db/microarray/test_ncbi_geo.rb
#
# See http://github.com/pjotrp/bioruby/wikis for more information
#
# Pjotr Prins

require 'uri'
require 'net/http'
require "rexml/document"

module Bio

  module Microarray

    module GEO

      module XML

        include REXML
        # Factory method to create an appropriate class based on the accession (GPL, GSE, GSM)
        #
        # Example: 
        #
        #    geo = Bio::Microarray::GEO::XML.create('GSE1007')
        #    p geo    # a GSE object

        def XML::create acc
          if valid_accession?(acc)
            @geo_class = nil
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

        # Fetch an XML definition from the NCBI site.
        def XML::fetch xmlfn, acc
          url = "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=#{acc}&form=xml&view=brief&retmode=xml" 
          print "Fetching ",url,"\n" if $VERBOSE
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
            cache = Cache.instance.directory
            fn = cache+'/'+acc+'.xml'
            if !File.exist?(fn)
              XML::fetch(fn,acc)
            end
            print "Parsing #{fn}\n" if $VERBOSE
            doc = Document.new File.new(fn)
            # return XmlSimple.xml_in(fn, { 'KeyAttr' => 'name' })
            return doc
          end
          nil
        end

        def XML::class_item xml, name
          return nil if xml==nil
          elements = xml.elements["*/#{@geo_class}/#{name}"]
          if elements
            return elements.first.to_s
          end
          nil
        end

        def XML::xpath xml, path
          path = '/MINiML'+path
          match = XPath.first(xml,path)
          match
        end
      end

      # Base class for GEO objects
      class GEOBase
        include XML

        def initialize acc
          @geo_class = 'unknown'
          @xml = XML::parsexml acc
          @acc = acc
        end

        def valid_accession? 
          XML::valid_accession? @acc
        end

        def title 
          if @xml
            XML::class_item(@xml,'Title').strip
          else
            @acc
          end
        end

        def xpath path
          XML::xpath @xml,path
        end

        # GEOBase tries to match XML elements when an unknown method is called.
        # For example Supplementary-Data is fetched when supplementary_data is called.
        #
        def method_missing(m, *args)  
          # convert method to XML element name and call 
          item = XML::class_item(@xml,m.to_s.split('_').each { | part | part.capitalize! } .join('-'))
          raise "Unknown method/element #{m}" if item == nil
          item.strip 
        end  
      end

      # GPL class represents GPL accession
      class GPL < GEOBase

        def initialize acc
          @geo_class = 'Platform'
          super
        end

        # def organism
        #   XML::class_item(@xml,'Organism').strip
        # end

      end

      class GSE < GEOBase

        def initialize acc
          @geo_class = 'Series'
          super
        end

      end


      # A GEO GSM object. Usage:
      #
      #    gsm = Bio::Microarray::GEO::XML.create('GSM53110')
      #    gsm.title
      #    > 'Breast - 29245'
      #    gsm.supplementary_data
      #    > ftp://ftp.ncbi.nih.gov/pub/geo/DATA/supplementary/samples/GSM53nnn/GSM53110/GSM53110.CEL.gz'
      #    gsm.xpath('/Database/Name').to_s
      #    > 'Gene Expression Omnibus (GEO)'

      class GSM < GEOBase

        def initialize acc
          @geo_class = 'Sample'
          super
        end

      end

    end # GEO
  end # Microarray
end # Bio
