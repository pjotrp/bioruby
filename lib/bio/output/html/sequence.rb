#
# = bio/output/html/sequence.rb - HTML sequence output
#
# Copyright::  Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl>
#
# License::    The Ruby License
#

require 'cgi'

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
    #   :escape_html    Escape HTML (default true)
    def initialize sequence, options = { :scheme => ColorScheme::Zappo }
      @seq = sequence
      @scheme = options[:scheme]
      @escape_html = options[:escape_html]
      @escape_html = true if @escape_html==nil
    end

    # Color each acid using the color scheme. Note that embedded HTML
    # will be escaped by default
    def html_color
      ret = ''
      postfix = '</span>'
      seq = escape_html(@seq)
      seq.each_byte do | c |
        c = c.chr
        color = @scheme[c]
        prefix = %Q(<span style="background:\##{color};">)
        ret += prefix + c + postfix
      end
      ret
     end

    # :nodoc:
    def escape_html buf
      return CGI.escapeHTML(buf) if @escape_html
      buf
    end

  end # HtmlSequence

end # Bio::Html
