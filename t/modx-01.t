use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://modx.ru/');
is($cd->getCms, CMS::Detector::CMS_MODX,'MODx: Check for http://modx.ru/');

$cd = detectCms('http://belka48.ru/');
is($cd->getCms, CMS::Detector::CMS_MODX,'MODx: Check for http://belka48.ru/');

$cd = detectCms('http://plangeo.ru/');
is($cd->getCms, CMS::Detector::CMS_MODX,'MODx: Check for http://plangeo.ru/');

done_testing;