use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://modx.ru/');
is($cd->getCms, CMS::Detector::CMS_MODX,'MODx: Check for http://modx.ru/');

$cd = DetectCms('http://belka48.ru/');
is($cd->getCms, CMS::Detector::CMS_MODX,'MODx: Check for http://belka48.ru/');

$cd = DetectCms('http://plangeo.ru/');
is($cd->getCms, CMS::Detector::CMS_MODX,'MODx: Check for http://plangeo.ru/');

done_testing;