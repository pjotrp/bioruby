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

    def test_fields
      Bio::Microarray::Cache.instance.set('/tmp')
      geo = Bio::Microarray::GEO::XML.create('GSM53110')
    end

  end

end
