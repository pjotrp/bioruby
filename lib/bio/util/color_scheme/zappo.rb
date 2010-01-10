#
# bio/util/color_scheme/zappo.rb - Zappo color codings for amino acids
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: zappo.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/util/color_scheme'

module Bio::ColorScheme
  class Zappo < Simple #:nodoc:

    # Return an HTML description
    def self.html_help()
      return <<EOH
<p /><em>Zappo Colours</em><p />
  <table width="400" border="1">
    <tr>
      <td > Aliphatic/hydrophobic</td>
      <td bgcolor="#ffafaf">ILVAM </td>
    </tr>
    <tr>
      <td>Aromatic</td>
      <td bgcolor="#ffc800">FWY</td>

    </tr>
    <tr>
      <td>Positive</td>
      <td bgcolor="#6464ff">KRH</td>
    </tr>
    <tr>
      <td> Negative</td>

      <td bgcolor="#ff0000">DE</td>
    </tr>
    <tr>
      <td>Hydrophilic</td>
      <td bgcolor="#00ff00">STNQ</td>
    </tr>
    <tr>

      <td>conformationally special</td>
      <td bgcolor="#ff00ff">PG</td>
    </tr>
    <tr>
      <td>Cysteine</td>
      <td bgcolor="#ffff00">C</td>
    </tr>
  </table>
</div>
<p />
EOH
    end

    #########
    protected
    #########

    @colors = {
      'A' => 'FFAFAF',
      'C' => 'FFFF00',
      'D' => 'FF0000',
      'E' => 'FF0000',
      'F' => 'FFC800',
      'G' => 'FF00FF',
      'H' => 'FF0000',
      'I' => 'FFAFAF',
      'K' => '6464FF',
      'L' => 'FFAFAF',
      'M' => 'FFAFAF',
      'N' => '00FF00',
      'P' => 'FF00FF',
      'Q' => '00FF00',
      'R' => '6464FF',
      'S' => '00FF00',
      'T' => '00FF00',
      'U' => 'FFFFFF',
      'V' => 'FFAFAF',
      'W' => 'FFC800',
      'Y' => 'FFC800',

      'B' => 'FFFFFF',
      'X' => 'FFFFFF',
      'Z' => 'FFFFFF',
    }
    @colors.default = 'FFFFFF'  # return white by default

  end
end
