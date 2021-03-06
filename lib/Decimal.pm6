use v6;

#------------------------------------------------------------------------------
class X::Decimal is Exception {
  has Str $!message;
  has Str $!type;

  #----------------------------------------------------------------------------
  submethod BUILD ( :$!message, :$!type ) { }

  #----------------------------------------------------------------------------
  method message ( --> Str ) {
    "Error: $!message, type = $!type";
  }
}

#------------------------------------------------------------------------------
package Decimal:auth<github:MARTIMM> {

  constant C-ZERO-ORD = '0'.ord;

  # Decimal 32 bits values
  #constant C--D32 = ;

  # Decimal 64 bits values
  #constant C--D64 = ;

  # Decimal 128 bits values
  constant C-BITS-D128 = 128;
  constant C-BUFLEN-D128 = 16;
  constant C-EXPCONT-D128 = 12;
  constant C-TOTEXP-D128 = 14;
  constant C-COEFCONT-D128 = 110;
  constant C-TOTCOEFDIG-D128 = 34;
  constant C-EMAX-D128 = 6144;
  constant C-EMIN-D128 = -6143;
  constant C-ELIMIT-D128 = 12287;
  constant C-BIAS-D128 = 6176;

  #constant C--D128 = ;

  #----------------------------------------------------------------------------
  enum endianness <little-endian big-endian system-endian>;

  our $endian = little-endian;

}
