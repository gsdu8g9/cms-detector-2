use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://deti-karlovyvary.com/');
is($cd->getCms, CMS::Detector::CMS_SETUPRU,'Check for http://deti-karlovyvary.com/');

$cd = detectCms('http://disoptorg.ru/');
is($cd->getCms, CMS::Detector::CMS_SETUPRU,'Check for http://disoptorg.ru/');

done_testing;