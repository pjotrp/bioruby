#
# = bio/db/microarray.rb - Microarray database classes
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#
# $Id$
#

# definition of the Bio::Microarray classes

module Bio #:nodoc:

  module Microarray

    autoload :Cache, 'bio/db/microarray/cache'
    autoload :GEO, 'bio/db/microarray/ncbi_geo/geo'
    autoload :MINiML, 'bio/db/microarray/miniml/miniml'
    autoload :AffyProbemap, 'bio/db/microarray/affymetrix/affyprobemap'
    autoload :Affy, 'bio/db/microarray/affymetrix/affy'

  end #class Microarray
end #module Bio


