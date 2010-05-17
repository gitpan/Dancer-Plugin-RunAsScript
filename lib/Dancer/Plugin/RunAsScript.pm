package Dancer::Plugin::RunAsScript;
BEGIN {
  $Dancer::Plugin::RunAsScript::VERSION = '0.01';
}
# ABSTRACT: Easily run your dancer application as a cgi script!

use Dancer ':syntax';
use Dancer::Plugin;

my $settings = plugin_setting;

{
    my $utilize = 1;
    if ( defined $settings->{execute} && lc($settings->{execute}) eq lc('off') ) {
        $utilize = 0;
    }
    if ($utilize) {
        
        no warnings 'redefine';
        sub Dancer::Handler::Standalone::start {
            
            my $ipaddr = Dancer::setting('server');
            my $port   = Dancer::setting('port');
            
            my $dancer = Dancer::Handler::Standalone->new($port);
            $dancer->host($ipaddr);
        
            my $app = sub {
                my $env = shift;
                # ????
                $env->{REQUEST_URI} = $env->{PATH_INFO};
                undef $env->{SCRIPT_NAME};  
                my $req = Dancer::Request->new($env);
                $dancer->handle_request($req);
            };
        
            Dancer::Route->init();
            
            require Dancer::Plugin::RunAsScript::HackedPlack;
            Plack::Server::CGI->run($app);
    
        }
        
    }
}


1;

__END__
=pod

=head1 NAME

Dancer::Plugin::RunAsScript - Easily run your dancer application as a cgi script!

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::RunAsScript;
    
    post '/' => sub {
        ...
    };
    
    dance;

Important Note! Remember that you may need to use relative paths in your
templates when switching back/forth between embedded-server/script modes.

=head1 DESCRIPTION

Provides an easy way of running a dancer application as a cgi-script. This
functionality may be useful for someone not wishing to serve their application
using the default methods of deployment.

=head1 CONFIGURATION

There is no configuration needed for this functionality. Simple use the plugin
when you wish to run your application as a cgi-script!

=head1 AUTHOR

  Al Newkirk <awncorp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by awncorp.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

