use Test::More;
BEGIN { use_ok ( 'CMS::Detector', 'detectCms' ); }
use strict;
my $cd;

$cd = detectCms('http://www.bitrix.ru');
is($cd->getCms, CMS::Detector::CMS_BITRIX,'Bitrix:Check for http://www.bitrix.ru');

$cd = detectCms('http://thestore.ru/');
is($cd->getCms, CMS::Detector::CMS_BITRIX,'Bitrix:Check for http://thestore.ru/');

my $cd = detectCms('http://www.shatura.com/');
is($cd->getCms, CMS::Detector::CMS_BITRIX,'Bitrix:Check for http://www.shatura.com/');


done_testing;