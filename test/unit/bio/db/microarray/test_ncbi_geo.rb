#
# test/unit/bio/db/microarray/test_ncbi_geo.rb - Unit test for Bio::Microarray::GEO
#
# Author::    Pjotr Prins
# License::   The Ruby License
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

    def test_fields
      gsm = Bio::Microarray::GEO::XML.create('GSM53110')
      assert_equal('Breast - 29245',gsm.title)
    end

  end

end
