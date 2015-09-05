use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://chelseablues.ru/');
is($cd->getCms, CMS::Detector::CMS_UCOZ,'Check for http://chelseablues.ru/');

$cd = DetectCms('http://soyuz-pisatelei.ru/');
is($cd->getCms, CMS::Detector::CMS_UCOZ,'Check for http://soyuz-pisatelei.ru/');

done_testing;