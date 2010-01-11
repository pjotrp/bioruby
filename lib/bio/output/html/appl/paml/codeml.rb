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

    # Create plugin with PositiveSites object
    def initialize sites, graph='graph'
      @sites = sites
      @graph = graph
    end

    # Short description of the positive selection method
    def descr
      # @codeml_data.class.to_s
      'dN/dS (Naive Bayesian)'
    end

    # Create a graph
    def info
      @sites.send(@graph)
    end

  end # HtmlPositiveSites

end # Bio::Html

