#
# = bio/output/html/appl/paml/codeml.rb - HTML output
#
# Copyright::  Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl>
#
# License::    The Ruby License
#

module Bio::Html

  class HtmlPositiveSites

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
    # So _graph_ can be one of 'graph', 'graph_omega', 'graph_AA' and 'color'.
    # The _descr_ parameter allows adding some extra information (e.g. the Model)
    def initialize sites, graph='graph', descr=''
      @sites = sites
      @graph = graph
      @extra_descr = descr
    end

    # Short description of the positive selection method
    def descr
      @extra_descr+' '+@sites.descr
    end

    # Create a graph - return an (HTML) String 
    def info
      if @graph=='color'
        color()
      else
        @sites.send(@graph)
      end
    end

    # Return a color HTML graph
    def color
      @sites.graph_omega
    end

    # Return some help
    def html_help
      ret = <<INFO
      <p />
      Sites showing evidence of positive selection pressure. Number is 
      posterior mean of dN/dS (w) and an asterisk '*' when w>9.
      <p />
INFO
      ret += '<pre>'+@sites.to_s+'</pre>'
      ret
    end

  end # HtmlPositiveSites

end # Bio::Html

