use v6;
use Test;

use Decimal::D128;

#-------------------------------------------------------------------------------
subtest 'string parse', {
  my Decimal::D128 $d128 .= new(:str<0>);
  is +$d128, 0, 'Number 0';

  $d128 .= new(:str<-12>);
  is +$d128, -12, 'Number -12';

  $d128 .= new(:str<4E+6>);
  is +$d128, 4_000_000, 'Number 4000000';

  $d128 .= new(:str<0.73e-2>);
  is +$d128, 0.007299, 'Number 0.007299 - float representation of 0.73e-2';
  is ~$d128, '0.73e-2', 'String 0.73e-2';

  $d128 .= new(:str<.12>);
  is ~$d128, '.12', 'String .12';

  $d128 .= new(:str<12.>);
  is ~$d128, '12.0', 'String 12. accepted but converted to 12.0 to coerse to ';

  $d128 .= new(:str<-Inf>);
  is ~$d128, '-Inf', 'String -Inf';

  $d128 .= new(:str<-NaN>);
  is ~$d128, '-NaN', 'String -NaN';

  $d128 .= new(:str<2e3.2>);
  is ~$d128, 'NaN', 'Illegal number 2e3.2 -> NaN';
}

#-------------------------------------------------------------------------------
done-testing;
