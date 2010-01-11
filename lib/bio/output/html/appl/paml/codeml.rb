#
# = bio/output/html/appl/paml/codeml.rb - HTML output
#
# Copyright::  Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl>
#
# License::    The Ruby License
#

module Bio::Html

  class HtmlPositiveSites

    COLORS = ['FFFFFF', 'FFFFCC', 'FFFF99', 'FFCC00', 'FF9900', 'FF6600', 'FF0000']

    # == Description
    #
    # A class for creating HTML (colorized) line for positive selection sites.
    #
    # This class can act as a plugin to HtmlAlignment for adding an extra
    # information line.
    #
    # == Examples
    #

    # Create plugin with PositiveSites object. Standard graphs are available
    # from the PositiveSites object. In addition you can choose _graph_='color'.
    # So _graph_ can be one of 'graph', 'graph_omega', 'graph_AA' and 'graph_color'.
    #
    # The _descr_ parameter allows adding some extra information
    def initialize sites, graph='graph', descr=''
      @sites = sites
      @graph = graph
      @extra_descr = descr
    end

    # Short description of the positive selection method - this is called by
    # HtmlAlignment
    def descr
      @extra_descr+' '+@sites.descr
    end

    # Create a graph - return an (HTML) String - this is called by
    # HtmlAlignment
    def info
      if @graph=='graph_color'
        graph_color()
      else
        @sites.send(@graph)
      end
    end

    # Return a color HTML graph based on probability
    def graph_color
      colors = COLORS
      @sites.graph_to_s(lambda { |site| 
          symbol = "*"
          symbol = site.omega.to_i.to_s if site.omega.abs <= 10.0
          color = case site.probability
                    when 0.1..0.5 then colors[1]
                    when 0.5..0.8 then colors[2]
                    when 0.9..0.95 then colors[4]
                    when 0.95..0.99 then colors[5]
                    when 0.99..1.0 then colors[6]
                    else colors[0]
                  end
          html_colorize(symbol, color)
      }, '&nbsp')
    end

    # Create a colored cell
    def html_colorize c, color
      prefix = %Q(<span style="background:\##{color};">)
      prefix + c.to_s + '</span>'
    end

    # Return some help
    def html_help
      ret = <<INFO
      <p />
      <i>Sites showing evidence of positive selection pressure. Number is 
      posterior mean of dN/dS (w) and an asterisk '*' when w>9. The color
      coding reflects the probability:</i>
      <table border="1">
        <tr>
          <td > 0.1 &lt; p &lt; 0.5</td>
          <td bgcolor="##{COLORS[1]}">&nbsp;&nbsp;&nbsp;</td>
        </tr>
        <tr>
          <td > 0.5 &lt; p &lt; 0.8</td>
          <td bgcolor="##{COLORS[2]}">&nbsp;&nbsp;&nbsp;</td>
        </tr>
        <tr>
          <td > 0.8 &lt; p &lt; 0.9</td>
          <td bgcolor="##{COLORS[3]}">&nbsp;&nbsp;&nbsp;</td>
        </tr>
        <tr>
          <td > 0.9 &lt; p &lt; 0.95</td>
          <td bgcolor="##{COLORS[4]}">&nbsp;&nbsp;&nbsp;</td>
        </tr>
        <tr>
          <td > 0.95 &lt; p &lt; 0.99</td>
          <td bgcolor="##{COLORS[5]}">&nbsp;&nbsp;&nbsp;</td>
        </tr>
        <tr>
          <td > 0.99 &lt; p &lt; 1.0</td>
          <td bgcolor="##{COLORS[6]}">&nbsp;&nbsp;&nbsp;</td>
        </tr>
      </table>
      <p />
INFO
      ret += '<pre>'+@sites.to_s+'</pre>'
      ret
    end

  end # HtmlPositiveSites

end # Bio::Html

