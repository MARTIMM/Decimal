use v6;

#------------------------------------------------------------------------------
unit package Decimal:auth<github:MARTIM>;

use Decimal;

#------------------------------------------------------------------------------
class Actions {

  has Str $.characteristic;
  has Str $.mantissa;
  has Bool $.dec-negative;
  has Bool $.is-nan;
  has Bool $.is-inf;

  has Str $.exponent;
  has Bool $.exp-negative;

  #----------------------------------------------------------------------------
  method initialize ( Match $m ) {
    $!dec-negative = False;
    $!characteristic = '';
    $!mantissa = '';
    $!is-nan = False;
    $!is-inf = False;

    $!exp-negative = False;
    $!exponent = '0';
  }

  #----------------------------------------------------------------------------
  method decimal-part ( Match $m ) {
  }

  #----------------------------------------------------------------------------
  method exponent-part ( Match $m ) {
  }

  #----------------------------------------------------------------------------
  method numeric-string ( Match $m ) {
#note $m;
    $!dec-negative = ~($m<sign> // '') eq '-';
    $!characteristic = ~($m<numeric-value><decimal-part><characteristic> // '');
    $!mantissa = ~($m<numeric-value><decimal-part><mantissa> // '');
    $!is-nan = $m<nan>.defined;
    $!is-inf = $m<numeric-value><infinity>.defined;

    $!exp-negative = ~($m<numeric-value><exponent-part><sign> // '') eq '-';
    $!exponent = ~($m<numeric-value><exponent-part><exponent> // '0');

    # remove leading zeros from characteristic
    $!characteristic ~~ s/^ '0'+ //;

    # remove trailing zeros from mantissa
    $!mantissa ~~ s/ '0'+ $//;

#say 'ds: ', ~($m<sign> // '') eq '-';
note "\nV: $!dec-negative, $!characteristic, $!mantissa, $!is-nan, ",
     "$!is-inf, $!exp-negative, $!exponent";

  }
}
