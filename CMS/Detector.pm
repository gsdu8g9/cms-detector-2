package CMS::Detector;
 require Exporter;
 @ISA = qw/Exporter/;
 @EXPORT_OK = qw/detectCms/;
 use LWP::UserAgent;
 use HTML::TokeParser;
 use Net::DNS;
 use URI;
 use strict;
 use Hash::Util qw/lock_hash lock_keys/;
 our @cms;

BEGIN{
       no strict 'refs';
       @cms = qw/isWordpress isBitrix isDrupal isJoomla isMODx isDatalife isOpencart isSetupRu isUcoz/;
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
      $self->{ns} = [];

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
        my $uri = URI->new($url);

        my $ua = getUa();
        my $resp = $ua->get($url);
        die "Cannot get specified url:" . $resp->status_line if $resp->is_error;
        my $html = $resp->decoded_content;
        die "Empty result" if !$html;
        my $rv = CMS::Detector->new;

        my $resolver = Net::DNS::Resolver->new();
        my @parts = split /\./, $uri->host;

        #шлем асинхронные запросы к DNS по поводу NS-серверов доменов, начиная с верхнего уровня
        #и заканчивая вторым уровнем, т.е. для a.b.example.com 
        #пробуем a.b.example.com, b.example.com, example.com
        my @sockets;
        for(0 .. $#parts-1){
          my $tryingHost = join '.', @parts[ $_ .. $#parts];
          push @sockets, $resolver->bgsend($tryingHost,"NS");
        }
        
        #тут проверяем на CMS в том случае, если для проверки
        #не требуются NS-сервера
        #пока мы тут проверяем, ждет ответов от серверов
        checkForWordpress($url, $html, $rv);
        checkForBitrix($url, $html, $rv);
        checkForDrupal($url, $html, $rv);
        checkForJoomla($url, $html, $rv);
        checkForMODx($url, $html, $rv);
        checkForDatalife($url, $html, $rv);
        checkForOpencart($url, $html, $rv);

        while (my $s = shift @sockets){
          if($resolver->bgisready($s)){
             my $reply = $resolver->bgread($s);
             next if !$reply;
             push @{$rv->{ns}}, grep $_, map { $_->can('nsdname') && $_->nsdname } $reply->answer;
          }else{
             push @sockets, $s;
             sleep 1;
          }
        }

        checkForSetupRu($url, $html, $rv);
        checkForUcoz($url, $html, $rv);

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
     my $urlObj = URI->new($url);
     my $urlhost = $urlObj->host;

     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'script' and $attr->{src} =~ m!/wp-content/!){
             $attr->{src} = $urlObj->scheme . ":$attr->{src}" if $attr->{src} =~ m!^//!;
             my $uri = URI->new($attr->{src});
             next if $uri->can('host') && (split /\./,$uri->host)[-2,-1] ne (split /\./,$urlhost)[-2,-1];
             $rv->incIsWordpress;
           }elsif($tag eq 'link' and $attr->{href} =~ m!/wp-includes/!){
             $attr->{href} = $urlObj->scheme . ":$attr->{href}" if $attr->{href} =~ m!^//!;
             my $uri = URI->new($attr->{href});
             next if $uri->can('host') && (split /\./,$uri->host)[-2,-1] ne (split /\./,$urlhost)[-2,-1];
             $rv->incIsWordpress;
           }elsif($tag eq 'img' and $attr->{src} =~ m!/wp-content/!){
             $attr->{src} = $urlObj->scheme . ":$attr->{src}" if $attr->{src} =~ m!^//!;
             my $uri = URI->new($attr->{src});
             next if $uri->can('host') && (split /\./,$uri->host)[-2,-1] ne (split /\./,$urlhost)[-2,-1];
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

   sub checkForSetupRu{
     my($url, $html, $rv) = @_;
     $rv->incIsSetupRu if grep /setup\.ru$/, @{ $rv->{ns} };

     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'script'){
             my(undef, $txt, $is_data) = @{ $tp->get_token };
             $rv->incIsSetupRu if $txt =~ /window\.userSiteData/;
             $rv->incIsSetupRu if $txt =~ /userTariff :/;
           }
        }
     }
   }

   sub checkForUcoz{
     my($url, $html, $rv) = @_;
     $rv->incIsUcoz if grep /(uweb|ucoz)\.(ru|net)$/, @{ $rv->{ns} };

     my $tp = HTML::TokeParser->new(\$html);
     while(my $t = $tp->get_token){
        if($t->[0] eq 'S'){
           my(undef, $tag, $attr, $tsq, $text) = @$t;
           if($tag eq 'script' and $attr->{src} =~ /\.ucoz\.(ru|net)/ or
              $tag eq 'link' and $attr->{href} =~ /\.ucoz\.(ru|net)/
           ){
             $rv->incIsUcoz
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