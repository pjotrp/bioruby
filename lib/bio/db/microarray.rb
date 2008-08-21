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

    autoload :AffyProbemap, 'bio/db/microarray/affyprobemap'
    autoload :Affy, 'bio/db/microarray/affy'

  end #class Microarray
end #module Bio


