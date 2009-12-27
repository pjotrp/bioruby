#
# bio/db/clustalw.rb - Interface ClustalW/Muscle alignment files
#
# Author::    Pjotr Prins
# Copyright:: Copyright (c) 2009 Pjotr Prins <p@bioruby.org>
# License::   The Ruby License
#

require 'bio/sequence'

module Bio

  #
  # = Description
  # 
  # ALN/ClustalW2 format:
  #
  # ALN format was originated in the alignment program ClustalW2. The file starts
  # with word "CLUSTAL" and then some information about which clustal program was
  # run and the version of clustal used.
  #
  # e.g. "CLUSTAL W (2.1) multiple sequence alignment"
  # The type of clustal program is "W" and the version is 2.1.
  # The alignment is written in blocks of 60 residues.
  # Every block starts with the sequence names, obtained from the input sequence,
  # and a count of the total number of residues is shown at the end of the line.
  #
  # The information about which residues match is shown below each block of residues:
  #
  #    "*" means that the residues or nucleotides in that column are identical in all sequences in the alignment.
  #    ":" means that conserved substitutions have been observed.
  #    "." means that semi-conserved substitutions are observed.
  #
  #    An example is shown below.
  #
  #    CLUSTAL W 2.1 multiple sequence alignment
  #
  #    FOSB_MOUSE      ITTSQDLQWLVQPTLISSMAQSQGQPLASQPPAVDPYDMPGTSYSTPGLSAYSTGGASGS 60
  #    FOSB_HUMAN      ITTSQDLQWLVQPTLISSMAQSQGQPLASQPPVVDPYDMPGTSYSTPGMSGYSSGGASGS 60
  #                    ********************************.***************:*.**:******
  #
  # Muscle and other tools use a similar format. The header line may be different
  # and the sequence length '60' is optional.
  #
  # = Usage
  #
  # See the BioRuby tutorial
  #

  class ClustalwError < RuntimeError ; end  #:nodoc:

  # Aligned sequence information, used by Bio::Clustalw internally
  class ClustalwSequence
    attr_reader :id, :data
    def initialize id, s
      @id = id
      @data = s
    end
    # add sequence data to the strand
    def add s
      @data += s
    end
  end

  # Aligned sequence information container, used by Bio::Clustalw internally
  class ClustalwSequences
    def initialize
      @list = []
      @index = {}
    end
    def add id, data
      if @index[id] == nil
        @index[id] = ClustalwSequence.new(id, data)
        @list.push @index[id]
      else
        @index[id].add(data)
      end
    end
    def fetch_by_num num
      @list[num]
    end
  end

  class Clustalw

    attr_reader :header, :matches

    IDENTICAL='*'
    CONSERVED=':'
    SEMICONSERVED='.'
   
    # Constructor
    #
    # ---
    # *Arguments*
    # * +lines+: (_required_) contents Clustalw/ALN formatted file 
    # *Returns*:: Bio::Clustalw
    #
    def initialize(lines=nil)
      process(lines)
    end

    # Process a textual object for ALN data
    def process lines
      $stderr.print "Clustalw warning: unexpected empty buffer" if !lines or !lines.size
      @sequences = ClustalwSequences.new
      @matches = ''
      @header = lines[0].strip
      @header =~ /^(\S+)/
      id = $1
      raise ClustalwError, "Unknown ALN format #{id} in "+@header if id !~ /CLUSTAL|MUSCLE/
      each_seq_segment(lines[1..-1]) do | id, data |
        if id == '!!alnmetric!!'
          # metric line is treated different
          @matches += data
        else
          @sequences.add(id,data)
        end
      end
    end

    # Return a Bio::Sequence object from the alignment
    # ---
    # *Arguments*:
    # * (required) num : Integer
    # *Returns*:: Bio::Sequence
    def get_sequence num
      seq = @sequences.fetch_by_num(num)
      create_sequence(seq.data,seq.id)
    end

    # Return the alignment info as a string.
    #
    # The information about which residues match is shown below each block of residues:
    #
    #    "*" means that the residues or nucleotides in that column are identical in all sequences in the alignment.
    #    ":" means that conserved substitutions have been observed.
    #    "." means that semi-conserved substitutions are observed.
    def alignment_info
      @matches
    end
  private
    
    # Creates a Bio::Sequence object with sequence 'seq_str'
    # and definition 'definition'.
    # ---
    # *Arguments*:
    # * (required) _seq_str_: String
    # * (optional) _definition_: String
    # *Returns*:: Bio::Sequence
    def create_sequence( seq_str, definition = "" )
      seq = Bio::Sequence.auto( seq_str )
      seq.definition = definition
      seq
    end  

    # Yield each segment of a sequence
    def each_seq_segment lines
      seqstart = nil
      seqstop  = nil
      lines.each do | sline |
        s = sline.strip
        if s != ''
          if sline =~ /^\s+/
            yield '!!alnmetric!!',sline[seqstart..seqstop-1]
          else
            a = s.split
            sline =~ /^(\S+\s+)/
            idwide = $1
            if seqstart and seqstart != idwide.length
              raise ClustalwError, "Inconsistency (seqstart=#{seqstart}, expected #{idwide.length}) in "+sline
            else
              seqstart = idwide.length
              seqstop  = seqstart + a[1].length
            end
            yield a[0],a[1]
          end
        end
      end
    end
        
  end # Clustalw
end # Bio
