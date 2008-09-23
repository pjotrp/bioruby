#
# = bio/db/microarray/cache.rb - Caching support for remote microarray data
#
# Copyright::	Copyright (C) 2008 Pjotr Prins
# License::	The Ruby License
#

require 'singleton'
require 'fileutils'
require 'tmpdir'

module Bio

  module Microarray

    # The Cache singleton keeps track of disk caching. This is used for storing
    # XML file objects locally (like those of NCBI GEO).
    #
    class Cache
      include Singleton

      # Set the cache +directory+ and (optional) +subdir+ and create it if needed. 
      # If +safe+ is true (default) a SecurityError will be raised if the
      # directory has read/write access for all. If no cache dir is set an
      # automatic (safe) tmpdir is used.
      #
      # Returns: the cache directory
      #
      # Example:
      #
      #   cache =  Bio::Microarray::Cache.instance
      #   dir = cache.set                          # use BIORUBY_CACHE or a safe tmpdir
      #   dir = cache.set('/home/user/tmp','GEO')  # use your own
      #   dir = cache.set(Dir.getwd,'.cache')      # another possibility
      #
      def set(directory, subdir = nil, safe = true)
        dir = directory
        Dir.mkdir_p(dir) if !File.directory? dir
        if subdir
          dir = File.join(dir, subdir)
          Dir.mkdir(dir) if !File.directory? dir
          @subdir = subdir
        end
        @dir = dir
        if safe
          raise SecurityError if (File.stat(dir).mode & 0002) != 0
        end
        dir
      end

      # Return the cache directory - if it has not been set try environment
      # variables BIORUBY_CACHE and Ruby's (safe) TMPDIR first (if a directory
      # is world writable a security error will be raised).
      #
      # When +safe+ is true the use of /tmp is avoided.
      #
      # Returns: path to cache directory
      #
      def directory(subdir = nil, safe = true)
        if @dir==nil
          cache = ENV['BIORUBY_CACHE']
          if cache==nil or cache==''
            subdir = 'BIORUBY' if subdir==nil
            cache = Dir.mktmpdir(subdir)
            subdir = File.basename(cache)
            dir = File.dirname(cache)
            set(dir,subdir)
            return @dir
          end
          cache = ENV['TMPDIR'] if cache==nil or cache==''
          cache = Dir.tmpdir if cache==nil or cache==''
          set(cache, subdir)
          raise SecurityError if safe==true and (@dir == Dir.tmpdir or @dir == '')
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
        FileUtils.remove_entry_secure(@dir) if File.directory?(@dir)
      end

    end

  end # Microarray

end # Bio
