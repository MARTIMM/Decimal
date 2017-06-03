use v6;
use Test;

#-------------------------------------------------------------------------------
use Decimal::Dxxx;
my class X does Decimal::Dxxx { }

#-------------------------------------------------------------------------------
subtest 'decimal string to bcd', {
  my X $dxxx .= new(:str<234>);
  is +$dxxx, 234, 'number returned ok';
  is-deeply $dxxx.bcd(123), Buf.new( 0x23, 0x01), 'BCD 123 ok';
  is-deeply $dxxx.bcd(709223), Buf.new( 0x23, 0x92, 0x70), 'BCD 709223 ok';
  is-deeply $dxxx.bcd('872'), Buf.new( 0x72, 0x08), "BCD '872' ok";
}

#-------------------------------------------------------------------------------
subtest 'decimal string to bcd8', {
  my X $dxxx .= new(:str<234>);
  is-deeply $dxxx.bcd8(7031), Buf.new( 1, 3, 0, 7), 'BCD8 7031 ok';
  is-deeply $dxxx.bcd8('872'), Buf.new( 2, 7, 8), "BCD8 '872' ok";
}

#-------------------------------------------------------------------------------
done-testing;
