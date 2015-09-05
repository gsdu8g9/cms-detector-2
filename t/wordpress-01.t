use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://www.chip-top.ru');
is($cd->getCms, CMS::Detector::CMS_WORDPRESS,'Check for http://www.chip-top.ru');

$cd = detectCms('http://www.wordpress.org');
is($cd->getCms, CMS::Detector::CMS_WORDPRESS,'Check http://www.wordpress.org');

my $cd = detectCms('http://clicksor.com');
is($cd->getCms, CMS::Detector::CMS_WORDPRESS,'Check for http://clicksor.com');


done_testing;