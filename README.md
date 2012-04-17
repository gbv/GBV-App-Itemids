This repository contains a simple SeeAlso server to map GBV item identifiers.

# How this application was created

This is how it was created with 
[App::Padadoy](http://search.cpan.org/perldoc?App::Padadoy),
[Plack::App::SeeAlso](http://search.cpan.org/perldoc?PICA::Record), and
[PICA::Record](http://search.cpan.org/perldoc?PICA::Record):

    ~$ mkdir gbvitemids

    ~$ cd gbvitemids/

    ~$gbvitemids$ padadoy create GBV::App::Itemids
    [create] Writing default configuration to /home/voj/proj/gbvitemids/padadoy.conf
    [create] Using base directory /home/voj/proj/gbvitemids
    [create] app/
    [create] app/Makefile.PL
    [create] app/app.psgi (calling GBV::App::Itemids)
    [create] app/lib/GBV/App/
    [create] app/lib/GBV/App/Itemids.pm
    [create] app/t/
    [create] app/t/basic.t
    [create] data/
    [create] dotcloud.yml
    [create] deplist.txt -> app/deplist.txt
    [create] libs -> app/lib
    [create] logs/

    ~/gbvitemids$ vim lib/GBV/App/Itemids.pm
 
    ~/gbvitemids$ echo PICA::Record >> app/deplist.txt
    ~/gbvitemids$ echo Plack::App::SeeAlso >> app/deplist.txt
    ~/gbvitemids$ echo LWP::Simple >> app/deplist.txt

    ~/gbvitemids$ git init
    ~/gbvitemids$ git add * 
    ~/gbvitemids$ git add -f logs/.gitignore 
    ~/gbvitemids$ git commit -m "inital commit" 

    ~/gbvitemids$ git remote add origin git@github.com:gbv/GBV-App-Itemids.git
    ~/gbvitemids$ git push origin master

# How to start this application

    ~/gbvitemids$ plackup -r app/app.psgi 

