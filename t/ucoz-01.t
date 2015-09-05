use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://chelseablues.ru/');
is($cd->getCms, CMS::Detector::CMS_UCOZ,'Check for http://chelseablues.ru/');

$cd = detectCms('http://soyuz-pisatelei.ru/');
is($cd->getCms, CMS::Detector::CMS_UCOZ,'Check for http://soyuz-pisatelei.ru/');

done_testing;