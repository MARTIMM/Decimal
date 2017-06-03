use v6;
use Test;

#-------------------------------------------------------------------------------
use Decimal::Dxxx;
my class X does Decimal::Dxxx { }

#-------------------------------------------------------------------------------
subtest 'init decimal128 nummerator/denominator', {
  my X $dxxx .= new( 2, 4);
  isa-ok $dxxx, X;

  like ~$dxxx, /^ '0.5' /, 'can be coersed to string';
  is $dxxx * 2.3, 1.15, 'calculations can be done directly';
  ok ($dxxx * 2.3) ~~ FatRat, 'type of calculation is FatRat';

  ok +$dxxx ~~ FatRat, 'object coersed to return FatRat';
  is-approx (cos +$dxxx), 0.877582, 'cosine on coersed object';

  ok ?$dxxx, 'dxxx is not 0';
  $dxxx .= new( 0, 234);
  nok ?$dxxx, 'dxxx is 0';
  $dxxx = X;
  nok ?$dxxx, 'dxxx not defined';
}

#-------------------------------------------------------------------------------
subtest 'init decimal128 with Num and others', {
  my X $dxxx .= new(:num(1.34e4));
  is +$dxxx, 13400.0, 'Num init ok';

  $dxxx .= new(:rat(2/52));
  is-approx +$dxxx, 0.038462, 1e-5, 'Rat init ok';

  $dxxx .= new(:str<12.345>);
  is +$dxxx, 12.345, 'Str init ok';
}

#-------------------------------------------------------------------------------
done-testing;
