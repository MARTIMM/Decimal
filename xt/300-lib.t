use v6;
use Test;
use NativeCall;

#constant DFPAL = %?RESOURCES<lib/libDFPAL.so>;
constant DFPAL = 'resources/lib/libDFPAL.so';
#say "D: ", DFPAL;
#=finish

enum ROUNDING (
  'DEC_ROUND_CEILING',             #/* round towards +infinity         */
  'DEC_ROUND_UP',                  #/* round away from 0               */
  'DEC_ROUND_HALF_UP',             #/* 0.5 rounds up                   */
  'DEC_ROUND_HALF_EVEN',           #/* 0.5 rounds to nearest even      */
  'DEC_ROUND_HALF_DOWN',           #/* 0.5 rounds down                 */
  'DEC_ROUND_DOWN',                #/* round towards 0 (truncate)      */
  'DEC_ROUND_FLOOR',               #/* round towards -infinity         */
  'DEC_ROUND_05UP',                #/* round for reround               */
  'DEC_ROUND_MAX'                  #/* enum must be less than this     */
);

constant DECDPUN = 3;
constant DECNUMDIGITS = 34;
constant DECNUMUNITS = ((DECNUMDIGITS+DECDPUN-1)/DECDPUN);

constant DECIMAL128_Bytes = 16;

class decContext is repr('CStruct') {
  has int32  $!digits;             #/* working precision               */
  has int32  $!emax;               #/* maximum positive exponent       */
  has int32  $!emin;               #/* minimum negative exponent       */
  #enum  rounding round;
  has int32  $!round;              #/* rounding mode                   */
  has uint32 $!traps;              #/* trap-enabler flags              */
  has uint32 $!status;             #/* status flags                    */
  has uint8  $!clamp;              #/* flag: apply IEEE exponent clamp */
  #if DECSUBSET (by default 0)
  #uint8_t  extended;             #/* flag: special-values allowed    */
  #endif

  method new {
    self.bless( :traps(0), :digits(DECNUMDIGITS), :round(DEC_ROUND_HALF_EVEN));
  }
}

class decNumber is repr('CStruct') {
  has int32 $!digits;
  has int32 $!exponent;
  has uint8 $!bits;
  #has decNumberUnit (= uint16)...;
  has CArray $!lsu;

  method new {
    self.bless(:lsu(0x0000 xx DECNUMUNITS));
  }
}

class decimal128 is repr('CStruct') {
  has CArray $!bytes;               #/* decimal128: 1, 5, 12, 110 bits*/

  method new {
    self.bless(:bytes(0x0000 xx DECIMAL128_Bytes));
  }

  method bytes ( --> CArray ) { $!bytes }
}

sub decNumberFromString (
  decNumber is rw,
  Str is encoded('utf8'),
  decContext
) returns Pointer is native(DFPAL) { * }

sub decimal128FromNumber(
  decimal128 is rw,
  decNumber,
  decContext
) returns Pointer is native(DFPAL) { * }

#-------------------------------------------------------------------------------
subtest 'lib access', {
  my decContext $dc .= new;
  my decNumber $dn .= new;
  my decimal128 $d128 .= new;

  decNumberFromString( $dn, '1', $dc);
  decimal128FromNumber( $d128, $dn, $dc);

  note "\nN=1: ", $d128.bytes;

  say "dn: ", $dn.perl;
  say "$d128: ", $d128.perl;
}

#-------------------------------------------------------------------------------
done-testing;
