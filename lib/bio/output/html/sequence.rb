#
# = bio/output/html/sequence.rb - HTML sequence output
#
# Copyright::  Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl>
#
# License::    The Ruby License
#

module Bio::Html

  class HtmlSequence

    # == Description
    #
    # Create HTML (colorized) output from a Sequence object.
    #
    # == Examples
    #
    #   >> include Bio
    #   >> seq = Sequence::AA.new("LAAGPGRTVVNTHFHGDHAFGNQVFAP-GTRIIAHED")
    #   >> h = Html::HtmlSequence.new(seq)
    #   >> html = h.html_color
    #   >> File.open('test.html','w') {|f| f.write(html) }

    # _sequence_ is a Bio::Sequence object
    #
    # options can contain
    #
    #   :scheme         ColorScheme object
    def initialize sequence, options = { :scheme => ColorScheme::Zappo }
      @seq = sequence
      @scheme = options[:scheme]
    end

    def html_color
      ret = ''
      postfix = '</span>'
      @seq.each_byte do | c |
        color = @scheme[c.chr]
        prefix = %Q(<span style="background:\##{color};">)
        ret += prefix + c.chr + postfix
      end
      ret
     end

  end # HtmlSequence

end # Bio::Html
