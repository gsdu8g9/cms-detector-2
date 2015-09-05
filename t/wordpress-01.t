use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://www.chip-top.ru');
is($cd->getCms, CMS::Detector::CMS_WORDPRESS,'Check for http://www.chip-top.ru');

$cd = DetectCms('http://www.wordpress.org');
is($cd->getCms, CMS::Detector::CMS_WORDPRESS,'Check http://www.wordpress.org');

my $cd = DetectCms('http://clicksor.com');
is($cd->getCms, CMS::Detector::CMS_WORDPRESS,'Check for http://clicksor.com');


done_testing;