use v6;
use Test;

use Decimal::D128;

#-------------------------------------------------------------------------------
subtest 'encode decimal128', {
  my Decimal::D128 $d128 .= new(:num(Inf));
  my Buf $b = $d128.encode;
  is-deeply $b, Buf.new(
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x78,
  ), 'Inf ok';

  $d128 .= new(:num(-Inf));
  $b = $d128.encode;
  is-deeply $b, Buf.new(
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8,
  ), '-Inf ok';

  $d128 .= new(:num(NaN));
  $b = $d128.encode;
  is-deeply $b, Buf.new(
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7c
  ), 'NaN ok';

  $d128 .= new(:str<1>);
  $b = $d128.encode;
  is-deeply $b, Buf.new(
    0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x22,
  ), '1';

#`{{
  $d128 .= new( 2, 1);
  $b = $d128.encode;
  is-deeply $b, Buf.new(
      0x10, 0xd0, 0x3c, 0xf1, 0xfd, 0x7f, 0x00, 0x00,
      0x80, 0x05, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
    ),
    '2';

  $d128 .= new( 9999999999999999455752309870428160, 1);
  $b = $d128.encode;
  is-deeply $b, Buf.new(
      0xb0, 0xf6, 0xf1, 0x74, 0xff, 0x7f, 0x00, 0x00,
      0x80, 0x05, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
    ),
    '9999999999999999455752309870428160';
}}
}

#-------------------------------------------------------------------------------
done-testing;

#done-testing;
#=finish
