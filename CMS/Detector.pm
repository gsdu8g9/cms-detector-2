package CMS::Detector;
 require Exporter;
 @ISA = qw/Exporter/;
 @EXPORT_OK = qw/detectCms/;
 use LWP::UserAgent;
 use HTML::TokeParser;
 use strict;
 use Hash::Util qw/lock_hash lock_keys/;
 our @cms;

BEGIN{
       no strict 'refs';
       @cms = qw/isWordpress isBitrix isDrupal isJoomla isMODx isDatalife isOpencart isSetupRu isUCoz/;
       for my $e (@cms){
           *{__PACKAGE__ . "::$e"} = sub { 
                       my($self, $val) = @_;
                       my $rv = $self->{cms}{$e};
                       if(defined $val){
                         $self->{cms}{$e} = $val;
                       }
                       return $rv;
            };
           *{__PACKAGE__ . "::inc" . ucfirst($e)} = sub { 
                       my($self, $val) = @_;                         
                       return ++$self->{cms}{$e};
            };

           *{__PACKAGE__ . "::CMS_" . do{local $_=$e; s/^is//; uc; }} = sub { 
                       return $e;
            };
       }
}

    sub new{
      my $class = shift;
      bless my $self={}, $class;
      @{ $self->{cms} }{ @cms }=0;      

      lock_keys %{$self->{cms}};
      lock_keys %$self;
      return $self;
    }
    sub getCms{
      my $self = shift;
      return (grep $self->{cms}{$_}, sort { $self->{cms}{$b} <=> $self->{cms}{$a} } keys %{$self->{cms}})[0];
    }

    sub detectCms{
        my($url) = @_;
        my $ua = getUa();
        my $resp = $ua->get($url);
        die "Cannot get specified url:" . $resp->status_line if $resp->is_error;
        my $html = $resp->decoded_content;
        die "Empty result" if !$html;
        my $rv = CMS::Detector->new;

        checkForWordpress($url, $html, $rv);
        checkForBitrix($url, $html, $rv);
        checkForDrupal($url, $html, $rv);
        checkForJoomla($url, $html, $rv);
        checkForMODx($url, $html, $rv);
        checkForDatalife($url, $html, $rv);
        checkForOpencart($url, $html, $rv);

        return $rv;
   }

   sub checkForWordpress{
     my($url, $html, $rv) = @_;
     checkForWordpressHtml($url, $html, $rv);
     checkForWordpressUrls($url, $html, $rv);
     return $rv;
   }
   
   sub checkForWordpressHtml{
     my($url, $html, $rv) = @_;

     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'script' and $attr->{src} =~ m!/wp-content/!){
             $rv->incIsWordpress;
           }elsif($tag eq 'link' and $attr->{href} =~ m!/wp-includes/!){
             $rv->incIsWordpress;
           }elsif($tag eq 'img' and $attr->{src} =~ m!/wp-content/!){
             $rv->incIsWordpress;
           }
        }
     }
   }

   sub checkForWordpressUrls{
     my($url, $html, $rv) = @_;
   }

   sub checkForBitrix{
     my($url, $html, $rv) = @_;

     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'script' and $attr->{src} =~ m!/bitrix/!){
             $rv->incIsBitrix;
           }elsif($tag eq 'link' and $attr->{href} =~ m!/bitrix/!){
             $rv->incIsBitrix;
           }elsif($tag eq 'img' and $attr->{src} =~ m!/bitrix/!){
             $rv->incIsBitrix;
           }
        }
     }
   }

   sub checkForDrupal{
     my($url, $html, $rv) = @_;
     $rv->incIsDrupal if $html =~ /Drupal/;
     $rv->incIsDrupal if getUa()->get("$url/misc/drupal.js")->is_success;
   }

   sub checkForJoomla{
     my($url, $html, $rv) = @_;
     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'meta' and $attr->{content} =~ m!Joomla!){
             $rv->incIsJoomla;
             last;
           }
        }
     }
     $rv->incIsJoomla if getUa()->get("$url/media/system/js/mootools.js")->is_success;
   }

   sub checkForMODx{
     my($url, $html, $rv) = @_;
     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'link' and $attr->{href} =~ m!/assets/(css|templates)!){
             $rv->incIsMODx;
           }elsif($tag eq 'img' and $attr->{src} =~ m!/assets/(images|templates)!){
             $rv->incIsMODx;
           }elsif(grep { m!modx/assets/snippets! } values %$attr){
             $rv->incIsMODx;
           }
        }
     }#get_token
   }

   sub checkForDatalife{
     my($url, $html, $rv) = @_;
     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'meta' and $attr->{content} =~ m!Datalife!i){
             $rv->incIsDatalife;
           }elsif($tag eq 'a' and $attr->{href} =~ m!dle-news.ru!){
             $rv->incIsDatalife;
             last;
           }
        }
     }
   }

   sub checkForOpencart{
     my($url, $html, $rv) = @_;
     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'a' and $attr->{href} =~ m!/index\.php\?route=\w+/\w+(&|;|$)!){
             $rv->incIsOpencart;
           }
        }
     }
   }


                               
   sub getUa{
     my $ua = LWP::UserAgent->new(cookie_jar => {});
     $ua->agent('Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)');
     $ua->default_header(Accept => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
     $ua->default_header('Accept-Encoding' => 'gzip, deflate');
     $ua->default_header('Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3');
     #$ua->default_header(Referer => 'http://ya.ru');
     return $ua;
   }
1;