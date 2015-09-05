use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://deti-karlovyvary.com/');
is($cd->getCms, CMS::Detector::CMS_SETUPRU,'Check for http://deti-karlovyvary.com/');

$cd = DetectCms('http://disoptorg.ru/');
is($cd->getCms, CMS::Detector::CMS_SETUPRU,'Check for http://disoptorg.ru/');

done_testing;