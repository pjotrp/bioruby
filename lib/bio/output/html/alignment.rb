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
    #--
    # The following few lines are not shown in the rdoc documentation
    #
    #   >> require 'bio'
    #   >> require 'bio/test/biotestfile'
    #   >> bufm0m3 = BioTestFile.read('paml/codeml/models/results0-3.txt')
    #   >> bufm7m8 = BioTestFile.read('paml/codeml/models/results7-8.txt')
    #   >> alnbuf = BioTestFile.read('paml/codeml/models/aa.aln')
    #++
    #
    # alnbuf contains the contents of a Clustal alignment file
    #
    #   >> include Bio
    #   >> aln = ClustalW::Report.new(alnbuf)
    #
    # Instantiate an HtmlAlignment object 
    #
    #   >> simple = Html::HtmlAlignment.new(aln.alignment, :title => "Clustal")
    #   >> html = simple.html()
    #
    # Ascertain we have a result
    #
    #   >> html[8..58]
    #   => "<pre>\nPITG_23265T0                            MKSQA"
    #
    # Write the HTML to a file (for viewing) with something like
    #
    #   >> File.open('test_bw.html','w') {|f| f.write(html) }
    #
    # Create nice colorized output for the alignments using the Zappo scheme
    # with the consensus line
    #
    #   >> colored = Html::HtmlAlignment.new(aln.alignment, :scheme => ColorScheme::Zappo)
    #   >> html = colored.html
    #   >> File.open('test_color.html','w') {|f| f.write(html) }
    # 
    # Now we want to add extra information to the alignment. In this example we
    # want to invoke Bioruby's PAML codeml parser, after having read the
    # contents of the codeml result file into _bufm0m3_ (for example using
    # File.read)
    #
    #   >> m0_3 = PAML::Codeml::Report.new(bufm0m3)
    #
    # First we create an HTML plugin for Codeml:
    #
    #   >> plugin = Html::HtmlPositiveSites.new(m0_3.nb_sites,'graph_color','M0-3')
    #
    # and add the output to the HtmlAlignment
    #
    #   >> colored.add_info_line(plugin)
    # 
    # Now we add another line containing the results for M7-8
    #
    #   >> m7_8 = PAML::Codeml::Report.new(bufm7m8)
    #   >> colored.add_info_line(Html::HtmlPositiveSites.new(m7_8.sites,'graph_color','M7-8'))
    # 
    # regenerate the HTML
    #
    #   >> html = colored.html
    #   >> File.open('test_color2.html','w') {|f| f.write(html) }
    #

    # Instantiate HtmlAlignment object where _alignment_ is a Bio::Alignment
    # type object.
    #
    # Supported options are
    #
    #   :title       The title
    #   :scheme      Color scheme (default Bio::ColorScheme::Zappo)
    #
    def initialize alignment, options = {}
      @alignment = alignment
      @options = options
      @info_plugins = []
    end

    # :nodoc:
    def add_info_line plugin
      @info_plugins.push plugin
    end

    # Show a section title
    def title
      return @options[:title] if @options[:title]
      ''
    end

    # Return credits in footer
    def footer
      scheme = @options[:scheme]
      ret = ''
      ret += scheme.html_help if scheme
      @info_plugins.each do | plugin |
        ret += plugin.html_help
      end
      ret += 'Generated by Bioruby Bio::HtmlAlignment'
      ret += ' ('+scheme.to_s+')' if scheme
      ret
    end

    # Return the consensus line (match_line)
    def consensus 
      @alignment.match_line
    end

    # HTML generator (color support planned for)
    #
    # Supported options _opts_ are 
    #
    #   :no_title      Don't show title
    #   :no_footer     Don't show footer
    def html(opts = { :ljust => 40 })
      if @options[:scheme]
        html_color(opts)
      else
        html_simple(opts)
      end
    end

    # The most simple form of HTML generator.
    #
    # Options can be set:
    #
    #   :ljust         Left adjust description/id (default 40)
    #
    # For the more supported options see html.
    def html_simple opts
      ljust = opts[:ljust]
      ret = ''
      ret += title+"\n" if not opts[:no_title]
      ret += "<pre>\n"
      @alignment.each_pair do | id, seq |
        ret += id.ljust(ljust)+seq+"\n"
      end
      ret += "Consensus".ljust(ljust)+consensus
      @info_plugins.each do | plugin |
        ret += "\n"+plugin.id.ljust(ljust)+plugin.info
      end
      ret += "\n</pre>"
      ret += footer if not opts[:no_footer]
      ret
    end

    # The color HTML generator.
    #
    # For the supported options see html
    def html_color opts
      ret = ''
      ret += title+"\n" if not opts[:no_title]
      ret += '<p /><font face="courier"><table>'+"\n"
      @alignment.each_pair do | id, seq |
        h = Html::HtmlSequence.new(seq)
        ret += '<tr><td style="white-space: nowrap">'+id+'</td><td>'+h.html_color+"</td></tr>\n"
      end
      ret += '<tr><td>Consensus</td><td>'+consensus.gsub(/\s/,'&nbsp;')+"</td></tr>\n"
      @info_plugins.each do | plugin |
        info = plugin.info
        info = "ERROR" if !info
        ret += '<tr><td style="white-space: nowrap">'+plugin.descr+'</td><td>'+info+"</td></tr>\n"
      end
      ret += "\n</table></font><p />"
      ret += footer if not opts[:no_footer]
      ret
    end

  end # Alignment

end # Bio::Html


