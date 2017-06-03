use v6;
use Test;

#-------------------------------------------------------------------------------
use Decimal::Dxxx;
my class X does Decimal::Dxxx { }

#-------------------------------------------------------------------------------
subtest 'string parse', {
  my X $dxxx .= new(:str<0>);
  is +$dxxx, 0, 'Number 0';

  $dxxx .= new(:str<-12>);
  is +$dxxx, -12, 'Number -12';

  $dxxx .= new(:str<4E+6>);
  is +$dxxx, 4_000_000, 'Number 4000000';

  $dxxx .= new(:str<0.73e-2>);
  is ~$dxxx, '0.73e-2', 'String 0.73e-2';

  $dxxx .= new(:str<.12>);
  is ~$dxxx, '.12', 'String .12';

  $dxxx .= new(:str<12.>);
  is ~$dxxx, '12.', 'String 12.';
  is +$dxxx, 12.0, 'String 12. accepted but converted to 12.0 to coerse to number';

  $dxxx .= new(:str<-Inf>);
  is ~$dxxx, '-Inf', 'String -Inf';

  $dxxx .= new(:str<-NaN>);
  is ~$dxxx, '-NaN', 'String -NaN';

  $dxxx .= new(:str<2e3.2>);
  is ~$dxxx, 'NaN', 'Illegal number 2e3.2 -> NaN';


  $dxxx .= new(:str<+12.215e-2>);
  is $dxxx.dec-negative, False, '+12.215e-2: not negative';
  is $dxxx.characteristic, '12', '+12.215e-2: characteristic is 12';
  is $dxxx.mantissa, '215', '+12.215e-2: mantissa is 215';
  is $dxxx.is-nan, False, '+12.215e-2: not NaN';
  is $dxxx.is-inf, False, '+12.215e-2: not Inf';
  is $dxxx.exp-negative, True, '+12.215e-2: exponent negative';
  is $dxxx.exponent, 2, '+12.215e-2: exponent is 2';
}

#-------------------------------------------------------------------------------
done-testing;
