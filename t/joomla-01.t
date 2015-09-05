use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://www.itwire.com/');
is($cd->getCms, CMS::Detector::CMS_JOOMLA,'Joomla: Check for http://www.itwire.com/');

$cd = DetectCms('http://www.joomla.org/');
is($cd->getCms, CMS::Detector::CMS_JOOMLA,'Joomla: Check for http://www.joomla.org/');

done_testing;