use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://www.drupal.org');
is($cd->getCms, CMS::Detector::CMS_DRUPAL,'Drupal: Check for http://www.drupal.org');


done_testing;