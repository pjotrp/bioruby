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
    #   >> simple.html
    #   => "xxx"
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
      buf = ""
      # fetch the alignments - is there a better way?
      @alignment.each_with_index do | seq, i |
        descr = @alignment.keys[i]
        buf += descr.ljust(40)+seq.seq+"\n"
      end
      buf
    end

  end # Alignment

end # Bio::Html


