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

      # Set the cache +directory+ and (optional) +subdir+ and create it if needed
      #
      # Returns: the cache directory
      #
      def set directory, subdir = nil
        dir = directory
        Dir.mkdir(dir) if !File.directory? dir
        if subdir
          dir = dir + '/' + subdir
          Dir.mkdir(dir) if !File.directory? dir
          @subdir = subdir
        end
        @dir = dir
        dir
      end

      # Return the cache directory - if it has not been set try environment
      # variables BIORUBY_CACHE and TMPDIR first
      def directory subdir = nil
        if @dir==nil
          cache = ENV['BIORUBY_CACHE']
          if cache==nil or cache==''
            cache = ENV['TMPDIR']
          end
          set cache, subdir
        end
        @dir
      end

      # Clear the current cache - will only do that when a subdir was 
      # defined (for reasons of safety)
      def clear
        return if not @subdir
        Dir.glob(directory+'/*') do | fn |
          File.unlink fn
        end
      end

      # Delete the cache subdirectory - only when subdir exists
      def delete
        return if not @subdir
        clear
        Dir.delete(directory)
      end

    end

  end # Microarray

end # Bio
