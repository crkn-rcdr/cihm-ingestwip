requires 'CIHM::TDR';
requires 'CIHM::Meta';
requires 'CIHM::METS::parse';
requires 'CIHM::METS::App';
requires 'CIHM::WIP', '0.17';
# Seems to be a problem compiling versions 4.51 and beyond... Likely problem with old perl, but not worth diagnosing at the moment...
requires 'IO::AIO', '==4.5';
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

# Used by CIHM::METS::App::Marc
requires 'MARC::Batch';
requires 'MARC::File::XML';
