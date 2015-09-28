Использование

   use CMS::Detector qw/DetectCms/;
   my $cd = DetectCms 'http://www.some.url';

   if($cd->getCms eq CMS::Detector::CMS_BITRIX){
     print "Bitrix detected!\n";
   }
   ...

 DetectCms 
 Возвращает результат попытки определения или выбрасывает исключение в случае ошибки.

 Методы
    $cd->getCms
       Возвращает используемую CMS. Возможные значения:

           CMS::Detector::CMS_WORDPRESS 
           CMS::Detector::CMS_BITRIX 
           CMS::Detector::CMS_DRUPAL 
           CMS::Detector::CMS_JOOMLA 
           CMS::Detector::CMS_MODX 
           CMS::Detector::CMS_DATALIFE 
           CMS::Detector::CMS_OPENCART 
           CMS::Detector::CMS_SETUPRU 
           CMS::Detector::CMS_UCOZ

    $cd->getFaviconUrl
           Возврашает урл favicon

 Исключения DetectCms
 В случае ошибки DetectCms выбрасывает исключение и 
 возвращает объект CMS::Detector::Exception

 local $@;
 my $cd = eval{ $cd };
 if($@){
    my $ex = $@;
 }

   $ex->{msg} - сообщение об ошибке
   $ex->{cause} - причина

 