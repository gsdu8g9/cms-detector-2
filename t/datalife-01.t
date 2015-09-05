use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://dle-news.ru/');
is($cd->getCms, CMS::Detector::CMS_DATALIFE,'MODx: Check for http://dle-news.ru/');

done_testing;