#
# = bio/db/microarray/cache.rb - Caching support for remote microarray data
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#

require 'singleton'

module Bio

  module Microarray

    # The Cache singleton keeps track of disk caching. This is used for storing
    # XML file objects locally (like those of NCBI GEO).
    #
    class Cache
      include Singleton

      # Set the cache directory and create it if needed
      def set directory
        if !File.directory? directory
          Dir.mkdir(directory)
        end
        @dir = directory
      end

      # Return the cache directory - if it has not been set we try environment
      # variables BIORUBY_CACHE and TMPDIR first
      def directory
        if @dir==nil
          cache = ENV['BIORUBY_CACHE']
          if cache==nil or cache==''
            cache = ENV['TMPDIR']
          end
          set cache
        end
        @dir
      end
    end

  end # Microarray

end # Bio
