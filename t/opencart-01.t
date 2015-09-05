use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://www.broadwalkfireseals.co.uk/');
is($cd->getCms, CMS::Detector::CMS_OPENCART,'Opencart: Check for http://opencartwebdevelopment.co.uk/');

$cd = DetectCms('http://www.opencart.com/');
is($cd->getCms, CMS::Detector::CMS_OPENCART,'Opencart: Check for http://www.opencart.com/');

$cd = DetectCms('http://www.intermit.co.uk/');
is($cd->getCms, CMS::Detector::CMS_OPENCART,'Opencart: Check for http://www.intermit.co.uk/');

done_testing;