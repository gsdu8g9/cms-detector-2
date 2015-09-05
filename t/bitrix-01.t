use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'DetectCms' ); }
use strict;
my $cd;

$cd = DetectCms('http://www.bitrix.ru');
is($cd->getCms, CMS::Detector::CMS_BITRIX,'Bitrix:Check for http://www.bitrix.ru');

$cd = DetectCms('http://thestore.ru/');
is($cd->getCms, CMS::Detector::CMS_BITRIX,'Bitrix:Check for http://thestore.ru/');

my $cd = DetectCms('http://www.shatura.com/');
is($cd->getCms, CMS::Detector::CMS_BITRIX,'Bitrix:Check for http://www.shatura.com/');


done_testing;