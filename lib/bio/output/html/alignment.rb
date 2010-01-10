#
# = bio/output/html/alignment.rb - HTML alignment output
#
# Copyright::  Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl>
#
# License::    The Ruby License
#

module Bio::Html

  class HtmlAlignment

    # == Description
    #
    # Create HTML colorized alignments from an Alignment object.
    # Extra information below the alignment, like evidence for
    # positive selection, can be added.
    #
    # == Examples
    #
    # Show evidence of positive selection pressure, as calculated
    # by PAML's codeml
    #
    #--
    # The following few lines are not shown in the rdoc documentation
    #
    #   >> require 'bio'
    #   >> require 'bio/test/biotestfile'
    #   >> buf = BioTestFile.read('paml/codeml/models/results0-3.txt')
    #   >> alnbuf = BioTestFile.read('clustalw/example1.aln')
    #++
    #
    # alnbuf contains the contents of a Clustal alignment file
    #
    #   >> aln = Bio::ClustalW::Report.new(alnbuf)
    #
    # Instantiate an HtmlAlignment object 
    #
    #   >> simple = Bio::Html::HtmlAlignment.new(aln.alignment)
    #   >> simple.html()[0..50]
    #   => "<pre>\nquery                                   -MKNT"
    # 
    #   !> colored = HtmlAlignment(aa_alignment,ColorScheme::Zappo)
    #   !> colored.add_positive_sites(codeml_positive_sites)
    #   !> colored.html
    #   !> "xxx"
    # 
    # Invoke Bioruby's PAML codeml parser, after having read the contents
    # of the codeml result file into _buf_ (for example using File.read)
    #
    #   !> codeml = Bio::PAML::Codeml::Report.new(buf)
    #

    # Instantiate HtmlAlignment object where _alignment_ is a Bio::Alignment
    # type object
    def initialize alignment
      @alignment = alignment
    end

    # HTML generator
    def html
      html_simple
    end

    # The most simple form of HTML generator
    def html_simple
      ret = "<pre>\n"
      @alignment.each_pair do | id, seq |
        ret += id.ljust(40)+seq+"\n"
      end
      ret + "</pre>"
    end

  end # Alignment

end # Bio::Html


