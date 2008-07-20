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

  class Microarray

    autoload :Affy, 'bio/db/microarray/affy'

  end #class Microarray
end #module Bio


