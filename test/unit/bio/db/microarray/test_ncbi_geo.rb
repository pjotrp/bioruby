#
# test/unit/bio/db/microarray/test_ncbi_geo.rb - Unit test for Bio::Microarray::GEO
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio'
require 'test/unit'

module Bio #:nodoc:

  class TestGEO < Test::Unit::TestCase #:nodoc:

    def setup
      @cache = Bio::Microarray::Cache.instance
      @cache.set('/tmp','test_geo')
    end

    def teardown
      @cache.delete
    end

    # Test downloading a definition from GEO and access various fields - naturally
    # you need Internet access for this.
    def test_gsm
      gsm = Bio::Microarray::GEO::XML.create('GSM53110')
      assert_equal('Breast - 29245',gsm.title)
      assert_equal('Patient Age: 60-70',gsm.description.split(/\n/)[1])
      assert_equal('ftp://ftp.ncbi.nih.gov/pub/geo/DATA/supplementary/samples/GSM53nnn/GSM53110/GSM53110.CEL.gz',gsm.supplementary_data)
      assert_equal('Gene Expression Omnibus (GEO)',gsm.xpath('/Database/Name').text.to_s)
    end

    def test_gpl
      gpl = Bio::Microarray::GEO::XML.create('GPL89')
      assert_equal('Affymetrix GeneChip Rat Toxicology U34 Array RT-U34',gpl.title)
      assert_equal('Rattus norvegicus',gpl.organism)
      assert_equal('Has 1031 entries and was indexed 29-Jan-2002',gpl.description.split(/\n/)[0])
    end

  end

end
