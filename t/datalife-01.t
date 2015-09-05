use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://dle-news.ru/');
is($cd->getCms, CMS::Detector::CMS_DATALIFE,'MODx: Check for http://dle-news.ru/');

done_testing;