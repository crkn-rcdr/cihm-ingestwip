requires 'Log::Log4perl';
requires 'common::sense';
requires 'MIME::Types';
requires 'Email::MIME';
requires 'Email::Sender::Simple';
requires 'Class::Singleton';
requires 'Config::General';
requires 'DateTime';
requires 'Date::Manip';
requires 'JSON';
requires 'JSON::XS';
requires 'Types::Standard';
requires 'MooseX::App';
requires 'MooseX::Log::Log4perl';
requires 'Capture::Tiny';
requires 'Role::REST::Client';
requires 'Crypt::JWT';
requires 'Switch';
# Installed outside
# requires 'Archive::BagIt', '== 0.053.3';
requires 'Archive::BagIt::App';
requires 'Filesys::Df';
requires 'BSD::Resource';
requires 'File::Copy::Recursive';
requires 'Text::CSV';
requires 'Text::CSV_XS';
requires 'Coro::Semaphore';
requires 'Image::Magick', '== 6.9.12';
requires 'AnyEvent';
requires 'AnyEvent::Fork';
requires 'AnyEvent::Fork::Pool';
requires 'XML::LibXSLT';
requires 'XML::LibXML';
requires 'IO::AIO';
requires 'XML::Dumper';

# Used by Mallet
requires 'File::Slurp';

# Used by CIHM::WIP::App::Walk
requires 'Filesys::DfPortable';

# Used by CIHM::Swift
requires 'Furl';
requires 'DateTime::Format::ISO8601';
