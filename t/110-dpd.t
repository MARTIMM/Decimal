use v6;
use Test;

#-------------------------------------------------------------------------------
use Decimal::Dxxx;
my class X does Decimal::Dxxx { }

#-------------------------------------------------------------------------------
subtest 'bcd8 to dpd', {
  my X $dxxx .= new(:str<234>);
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('245')), Buf.new( 0x45, 0x01), 'dpd 245';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('248')), Buf.new( 0x48, 0x01), 'dpd 248';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('295')), Buf.new( 0x5b, 0x01), 'dpd 295';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('298')), Buf.new( 0x5e, 0x01), 'dpd 298';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('945')), Buf.new( 0xcd, 0x02), 'dpd 945';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('948')), Buf.new( 0xae, 0x02), 'dpd 948';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('895')), Buf.new( 0x1f, 0x02), 'dpd 895';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('898')), Buf.new( 0x7e, 0x00), 'dpd 898';

  # tests from table on wiki
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('005')), Buf.new( 0x05, 0x00), 'dpd 005';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('009')), Buf.new( 0x09, 0x00), 'dpd 009';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('055')), Buf.new( 0x55, 0x00), 'dpd 055';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('079')), Buf.new( 0x79, 0x00), 'dpd 079';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('080')), Buf.new( 0x0a, 0x00), 'dpd 080';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('099')), Buf.new( 0x5f, 0x00), 'dpd 099';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('555')), Buf.new( 0xd5, 0x02), 'dpd 555';
  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('999')), Buf.new( 0xff, 0x00), 'dpd 999';

  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('945898')),
            Buf.new( 0x7e, 0x34, 0x0b), 'dpd 945898';

  is-deeply $dxxx.bcd2dpd($dxxx.bcd8('94589800')),
            Buf.new( 0x0c, 0x3c, 0xab, 0x05),
            'dpd 94589800';
}

#-------------------------------------------------------------------------------
done-testing;
