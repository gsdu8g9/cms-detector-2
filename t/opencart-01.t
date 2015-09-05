use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://www.broadwalkfireseals.co.uk/');
is($cd->getCms, CMS::Detector::CMS_OPENCART,'Opencart: Check for http://opencartwebdevelopment.co.uk/');

$cd = detectCms('http://www.opencart.com/');
is($cd->getCms, CMS::Detector::CMS_OPENCART,'Opencart: Check for http://www.opencart.com/');

$cd = detectCms('http://www.intermit.co.uk/');
is($cd->getCms, CMS::Detector::CMS_OPENCART,'Opencart: Check for http://www.intermit.co.uk/');

done_testing;