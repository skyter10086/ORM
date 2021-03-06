package Person;

use utf8::all;
use Carp;

#use ORM::Role::Model;
use ORM::Class::Field;
use ORM::Class::DB;

use Moose;
use namespace::autoclean;

has 'name' => ( is => 'rw', );

has 'id' => ( is => 'rw', );

with 'ORM::Role::Model';

sub Model {
    my $model = {
        'name' => ORM::Class::Field->new(
            type => 'VARCHAR',
            len  => 20,
        ),
        'id' => ORM::Class::Field->new(
            type => 'VARCHAR',
            len  => 18,
        ),
        'pk' => [qw/ id /],
    };
    return $model;
}

sub Db {
    my $db = ORM::Class::DB->new(
        dsn     => 'dbi:SQLite:dbname=test.db',
        user    => '',
        passwd  => '',
        options => { sqlite_unicode => 1, AutoCommit => 1, RaiseError => 1 },
    );
    return $db;
}

1;
