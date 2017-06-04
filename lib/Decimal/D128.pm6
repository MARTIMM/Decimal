use v6;

unit package Decimal:auth<github:MARTIMM>;

use Decimal;
use Decimal::Dxxx;

#------------------------------------------------------------------------------
# Decimal Encoding Specification at http://speleotrove.com/decimal/dbspec.html
# Densely Packed Decimal encoding at http://speleotrove.com/decimal/DPDecimal.htmlhttp://speleotrove.com/decimal/DPDecimal.html
# Wiki https://en.wikipedia.org/wiki/Binary-coded_decimal

# https://en.wikipedia.org/wiki/Decimal128_floating-point_format
# http://speleotrove.com/decimal/dbspec.html
# https://github.com/mongodb/specifications/blob/master/source/bson-decimal128/decimal128.rst#terminology
#------------------------------------------------------------------------------
class D128 does Decimal::Dxxx {

  #----------------------------------------------------------------------------
  # encode to BSON binary
  multi method encode ( --> Buf ) {
note "string and sign: $!string, ", self.dec-negative;

    # 34 digits precision of which one digit of 4 bits is merged into the
    # space of 3 bits and placed in the combination field together with 2 bits
    # from the exponent. Thus;

    # Combination
    # field (5 bits) 	 Type 	    Exponent       Coefficient
    #               	            MSBs (2 bits)  MSD (4 bits)
    # a b c d e 	     Finite 	  a b 	         0 c d e
    # 1 1 c d e 	     Finite 	  c d 	         1 0 0 e
    # 1 1 1 1 0 	     Infinity 	- - 	         - - - -
    # 1 1 1 1 1        NaN        - - 	         - - - -

    # For the rest of the precision 33 digits as DPD 33/3 * 10 = 110 bits
    # Leaves us an exponent of 128 - 1(sign) - 5(combination) - 110 = 12 bits
    # With 2 bits exponent in the combination field it gives a total of 14 bits.

    # Test for special cases NaN and Inf
    if self.is-nan {
      if self.dec-negative {
#`{{        # -NaN, signalling NaN
        #?? $!internal .= new( 0x00 xx 15, 0x7e);
        $!internal .= new( 0x00 xx 15, 0xfc);
}}
      }

      else {
        # NaN, quiet NaN
        $!internal .= new( 0x00 xx 15, 0x7c);
      }
    }

    elsif self.is-inf {
      if self.dec-negative {
        # -Inf
        $!internal .= new( 0x00 xx 15, 0xf8);
      }

      else {
        # +Inf
        $!internal .= new( 0x00 xx 15, 0x78);
      }
    }

    # all other finite cases
    else {

      # Process coefficient
      my Str $adj-coefficient = self.characteristic ~ self.mantissa;
      $adj-coefficient ~~ s/^ '0'+ //;

      # Check number of characters in coefficient
      die X::Decimal.new( :message("coefficient too big"), :type<decimal128>)
          if $adj-coefficient.chars > 34;
note "Coeff: $adj-coefficient";


      # Process exponent
      my Int $adj-exponent = -self.mantissa.chars;
      if self.exp-negative {
        $adj-exponent -= self.exponent.Int;
      }

      else {
        $adj-exponent += self.exponent.Int;
      }

      # Check for exponent then adjust for bias
      die X::Decimal.new( :message("exponent too large"), :type<decimal128>)
          if $adj-exponent > Decimal::C-EMAX-D128;
      die X::Decimal.new( :message("exponent too small"), :type<decimal128>)
          if $adj-exponent < Decimal::C-EMIN-D128;
      $adj-exponent += Decimal::C-BIAS-D128;
note "exp: $adj-exponent";


      # Create buffer
      # Reset any previous values
      $!internal .= new(0x00 xx 16);



      # Get the coefficient. The MSByte is at the end of the array
      # coerse to string, somehow in the process it became IntStr
      self.bcd8($adj-coefficient);
      self.bcd2dpd;
note 'dpd: ', $!dpd;

      # Copy 13 bytes and 6 bits into the result, a total of 110 bits for
      # 33 dpd digits
      for ^14 -> $i {
        $!internal[$i] = $!dpd[$i];
      }

      # Following is needed because the 2 bits map to a part of the last digit
      # which must go to the combination bits. on these 2 bits, the exponent
      # must start.
      $!internal[13] +&= 0x3f;
note "I 0: ", $!internal;

      # Set sign bit
      my Int $c = self.dec-negative ?? 0x80 !! 0x00;
note "c 0: ", $c.fmt('0b%08b');

      # Get the 34th digit and copy to combination bits. Position the bits to
      # the spot where it should come in the combination field.(take
      # the location in the internal last byte into account).
      $c +|= ($!dpd[13] +& 0xc0) +> 4;
      $c +|= (($!dpd[14] +& 0x03) +< 4);
note "c 1: ", $c.fmt('0b%08b');

      # If 34th digit larger than 7 then the bit at 0x20 is set. if so,
      # bit at 0x40 must be set too.
      $c +|= 0x40 if $c +& 0x20;
note "c 2: ", $c.fmt('0b%08b');


      # Get the exponent and copy 2 MSBits of it to the combination field
note "e: $adj-exponent, ", $adj-exponent.fmt('0x%04x');
      my $two-msb = $adj-exponent +& 0x3000;
note "e 2msb: ", $two-msb.fmt('0x%04x');
      # place at x-es in s11xxe if 34th digit > 7
      if $c +& 0x20 {
        $c +|= ($two-msb +> 9);
      }

      # place at x-es in sxxcde if 34th digit < 7
      else {
        $c +|= ($two-msb +> 7);
      }
note "c 3: ", $c.fmt('0b%08b');

      # copy component into the result
      $!internal[15] +|= $c;
note "I 1: ", $!internal;

      # copy the rest of the exponent
      # next two MSbits of exponent in first byte, then a byte, then last 2bits
      $!internal[15] +|= (($adj-exponent +& 0x0c00) +> 10);
      $!internal[14] +|= (($adj-exponent +& 0x03fc) +> 2);
      $!internal[13] +|= (($adj-exponent +& 0x0003) +< 6);
note "I 2: ", $!internal;
    }

#note "I n: ", $!internal;
    $!internal;
  }

  #----------------------------------------------------------------------------
  # decode from BSON binary
  method decode (
    Buf:D $b,
    Int:D $index is copy,
    --> Decimal::D128
  ) {

  }
}
