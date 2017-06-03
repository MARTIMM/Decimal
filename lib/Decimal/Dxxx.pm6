use v6;

class X::Decimal is Exception {
  has Str $!message;
  has Str $!type;
}

#------------------------------------------------------------------------------
package Decimal:auth<github:MARTIMM> {

  use Decimal;
  use Decimal::Actions;
  use Decimal::Grammar;

  #------------------------------------------------------------------------------
  role Dxxx:auth<github:MARTIMM> {

    has Buf $!internal .= new( 0x00 xx 16 );
    has Str $!string;

    has Buf $!dpd;
    has Buf $!bcd;
    has Buf $!bcd8;

    has Decimal::Actions $!actions handles
        < characteristic mantissa dec-negative is-nan is-inf
          exponent exp-negative
        >;

    #----------------------------------------------------------------------------
    # FatRat initialization
    multi submethod new ( $n, $d ) {
      self.bless(:number(FatRat.new( $n, $d)));
    }

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # other specialized initializations
    multi submethod new ( |c ) {
      self.bless(|c);
    }

    #----------------------------------------------------------------------------
    # FatRat initialization
    multi submethod BUILD ( FatRat:D :$number! ) {
      #$!is-inf = $!is-nan = False;
      $!string = $number.Str;
      $!actions .= new;
      my Match $m = Decimal::Grammar.parse( $!string, :rule<dxxx>, :$!actions);
    }

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # init using Rat
    multi submethod BUILD ( Rat:D :$rat! ) {
      $!string = $rat.Str;
      $!actions .= new;
      my Match $m = Decimal::Grammar.parse( $!string, :rule<dxxx>, :$!actions);
    }

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # init using Num. it is possible to define Inf and NaN with Num.
    multi submethod BUILD ( Num:D :$num! ) {

      $!string = $num.Str;
      $!actions .= new;
      my Match $m = Decimal::Grammar.parse( $!string, :rule<dxxx>, :$!actions);
    }

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # init using string
    multi submethod BUILD ( Str:D :str($!string)! ) {
  #say "SA: ", $!string.WHAT;
      $!actions .= new;
      my Match $m = Decimal::Grammar.parse( $!string, :rule<dxxx>, :$!actions);
  #say "SA: ", $!string.WHAT;
  #note 'M: ', $m;

      if ! $m.defined {
        $!string = 'NaN';

        # Force new values in Actions module
        Decimal::Grammar.parse( $!string, :rule<dxxx>, :$!actions);
      }
    }

    #----------------------------------------------------------------------------
    # return string representation for string concatenation
    method Str ( --> Str ) {
      $!string;
    }

    #----------------------------------------------------------------------------
    # return string representation for string concatenation
    method Bool ( --> Bool ) {
      self.defined and $!string !~~ m/^ 'NaN' || '0' $/;
    }

    #----------------------------------------------------------------------------
    # return a number when requeste for calculations
    method Numeric ( --> Numeric ) {

      # Add a 0 after the number when there is only a trailing dot
      my $s = $!string;
      $s ~= '0' if $s ~~ / '.' $/;
      $s.FatRat;
    }

    #----------------------------------------------------------------------------
    # compress BCD to Densely Packed Decimal
    method bcd2dpd( Buf $bcd8? --> Buf ) {

      $!bcd8 = $bcd8 // $!bcd8;
      die '8bit BCD buffer not defined' unless ? $!bcd8;

      # init result bits array
      my @dpd = ();

      # match to multple of 3 digits.
      while ! ($!bcd8.elems %% 3) {
        $!bcd8.push(0);
      }

      # Pack every 3 nibles (each in a byte) into 10 bits
      for @$!bcd8 -> $b1, $b2, $b3 {

        my @bit-array = ();
        @bit-array.push( |map {$_ - Decimal::C-ZERO-ORD}, $b1.fmt('%04b').ords.reverse );
        @bit-array.push( |map {$_ - Decimal::C-ZERO-ORD}, $b2.fmt('%04b').ords.reverse );
        @bit-array.push( |map {$_ - Decimal::C-ZERO-ORD}, $b3.fmt('%04b').ords.reverse );
  #note "bit array $b1, $b2, $b3 for dpd:    ", @bit-array;

        my Int $msb-bits = 0;
        my @dense-array = ();

        $msb-bits = (@bit-array[11] +< 2) +|        # $b3 sign -> msb
                    (@bit-array[7] +< 1) +|         # $b2 sign
                    (@bit-array[3]);                # $b1 sign
  #note "msb-bits for dpd: ", $msb-bits.fmt('%03b');

        # Compression: (abcd)(efgh)(ijkm) becomes (pqr)(stu)(v)(wxy)
        given $msb-bits {

          # 000 => bcd fgh 0 jkm 	All digits are small
          when 0b000 {
            @dense-array = |@bit-array[0..2], 0, |@bit-array[4..6],
                           |@bit-array[8..10];
          }

          # 001 => bcd fgh 1 00m   Right digit is large [this keeps 0-9 unchanged]
          # Same as for 0b000
          when 0b001 {
            @dense-array = @bit-array[0], 0, 0, 1, |@bit-array[4..6],
                           |@bit-array[8..10];
          }

          # 010 => bcd jkh 1 01m   Middle digit is large
          when 0b010 {
            @dense-array = @bit-array[0], 1, 0, 1, @bit-array[4],
                           |@bit-array[ 1, 2], |@bit-array[8..10];
          }

          # 011 => bcd 10h 1 11m   Left digit is small [M & R are large]
          when 0b011 {
            @dense-array = @bit-array[0], 1, 1, 1, @bit-array[4],
                           0, 1, |@bit-array[8..10];
          }

          # 100 => jkd fgh 1 10m   Left digit is large
          when 0b100 {
            @dense-array = @bit-array[0], 0, 1, 1, |@bit-array[4..6],
                           @bit-array[8], |@bit-array[ 1, 2];
          }

          # 101 => fgd 01h 1 11m   Middle digit is small [L & R are large]
          when 0b101 {
            @dense-array = @bit-array[0], 1, 1, 1, @bit-array[4],
                           1, 0, @bit-array[8], |@bit-array[ 5, 6];
          }

          # 110 => jkd 00h 1 11m   Right digit is small [L & M are large]
          when 0b110 {
            @dense-array = @bit-array[0], 1, 1, 1, @bit-array[4],
                           0, 0, @bit-array[8], |@bit-array[ 1, 2];
          }

          # 111 => 00d 11h 1 11m   All digits are large; two bits are unused
          when 0b111 {
            @dense-array = @bit-array[0], 1, 1, 1, @bit-array[4],
                           1, 1, @bit-array[8], 0, 0;
          }
        }

  #note 'dense array:', ' ' x 18, @dense-array;
        @dpd.push(|@dense-array);
      }
  #note 'dense array result: ', ' ' x 10, @dpd;

      # make multiple of 8 bits to fit bytes
      @dpd = @dpd; #.reverse;
      while ! (@dpd.elems %% 8) {
  #      @dpd.unshift(0);
        @dpd.push(0);
      }
  #note 'corrected dense array result: ', @dpd; #, ' (reversed)';

      $!dpd = Buf.new;
      for @dpd -> $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7 {
        $!dpd.push(:2(( $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7).reverse.join('')));
      }

  #note 'dpd: ', ' ' x 25, $!dpd;
      $!dpd;
    }

    #----------------------------------------------------------------------------
    multi method bcd ( Int $n --> Buf ) {
      self.bcd($n.Str);
    }

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Little endian of a BSD representation (BSON likes litle endian)
    multi method bcd ( Str $sn --> Buf ) {

      $!bcd .= new();

      my @nbrs = map {$_ - Decimal::C-ZERO-ORD}, $sn.ords.reverse;
      @nbrs.push(0) if @nbrs.elems +& 0x01;

      for @nbrs -> $digit1, $digit2 {
        my Int $byte = 0;
        $byte +|= $digit1;
        $byte +|= ($digit2 +< 4) if $digit2.defined;
        $!bcd.push($byte);
      }

      $!bcd;
    }


    #----------------------------------------------------------------------------
    multi method bcd8 ( Int $n --> Buf ) {
      self.bcd8($n.Str);
    }

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Little endian of a BSD representation (BSON likes litle endian).
    # One digit per byte. This is easier to process later on
    multi method bcd8 ( Str $sn --> Buf ) {
  #note "string for bcd8: $sn";

      $!bcd8 .= new();

      my @nbrs = map {$_ - Decimal::C-ZERO-ORD}, $sn.ords.reverse;
      for @nbrs -> $digit {
        $!bcd8.push($digit);
      }

  #note "bcd8: ", $!bcd8;
      $!bcd8;
    }
  }
}
