use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://www.drupal.org');
is($cd->getCms, CMS::Detector::CMS_DRUPAL,'Drupal: Check for http://www.drupal.org');


done_testing;