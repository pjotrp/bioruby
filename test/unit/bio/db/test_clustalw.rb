#
# test/unit/bio/db/test_clustalw.rb - Unit test for Bio::ClustalWFormat
#
# Copyright::  Copyright (C) 2009 Pjotr Prins <p@bioruby.org>
# License::    The Ruby License
#

require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s
require 'test/unit'
require 'bio/appl/clustalw/report'

module Bio

  class TestClustalWFormat < Test::Unit::TestCase

    def setup
      test_data_path = Pathname.new(File.join(BioRubyTestDataPath, 'clustalw')).cleanpath.to_s
      aln_filename = File.join(test_data_path, 'example1.aln')
      text = File.new(aln_filename).readlines
      @aln = Bio::ClustalW::Report.new(text.join)
    end

    # CLUSTAL 2.0.9 multiple sequence alignment
    #
    #
    # The alignment reads like:
    #
    # query                      -MKNTLLKLGVCVSLLGITPFVSTISSVQAERTVEHKVIKNETGTISISQ
    # gi|115023|sp|P10425|       MKKNTLLKVGLCVSLLGTTQFVSTISSVQASQKVEQIVIKNETGTISISQ
    #                                                                          .: :
    # 
    # query                      LNKNVWVHTELGYFSG-EAVPSNGLVLNTSKGLVLVDSSWDDKLTKELIE
    # gi|115023|sp|P10425|       LNKNVWVHTELGYFNG-EAVPSNGLVLNTSKGLVLVDSSWDNKLTKELIE
    #                                *:   .     .     **. .   ..   ::*:       . * :

    def test_header
      assert_equal('CLUSTAL 2.0.9 multiple sequence alignment',@aln.header)
    end

    def test_sequences
      seq = @aln.get_sequence(0)
      assert_equal('query',seq.definition)
      assert_equal('-MKNTLLKLGVCV',seq.to_s[0..12])
      seq = @aln.get_sequence(1)
      assert_equal('gi|115023|sp|P10425|',seq.definition)
      assert_equal('MKKNTLLKVGLCV',seq.to_s[0..12])
      # ascertain it is a BioRuby Bio::Sequence object
      assert_equal(Bio::Sequence::AA,seq.moltype)
    end

    def test_alignment
      assert_equal("???????????SN?????????????D??????????L??????????????????H?H?D",@aln.alignment.consensus[60..120])
    end

    def test_match_line
      assert_equal("                                              .: :    *:   .     .     **. .   ..   ::*:       . * : : .        .: .* * *",@aln.match_line[0..120])
    end

  end # class TestClustalwFormat

end
