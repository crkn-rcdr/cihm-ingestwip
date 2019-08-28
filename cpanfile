requires 'Log::Log4perl';
requires 'common::sense';
requires 'MIME::Types';
requires 'Email::MIME';
requires 'Email::Sender::Simple';
requires 'Class::Singleton';
requires 'Config::General';
requires 'DateTime';
requires 'JSON';
requires 'Types::Standard';
requires 'MooseX::App';
requires 'MooseX::Log::Log4perl';
requires 'Capture::Tiny';
requires 'Role::REST::Client';
requires 'Crypt::JWT';
requires 'Switch';
requires 'Archive::BagIt', '0.053.3';
requires 'Archive::BagIt::App';
requires 'Filesys::Df';
requires 'BSD::Resource';
requires 'File::Copy::Recursive';
requires 'Text::CSV';
requires 'Coro::Semaphore';
requires 'Image::Magick';
requires 'AnyEvent';
requires 'AnyEvent::Fork';
requires 'AnyEvent::Fork::Pool';

# Used by Mallet
requires 'File::Slurp';

# Used by CIHM::WIP::App::Walk
requires 'Filesys::DfPortable';

# Used by CIHM::METS::App::Marc
requires 'MARC::Batch';
requires 'MARC::File::XML';
