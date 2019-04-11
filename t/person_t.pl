use Person;
use Modern::Perl;
#use DBIx::Simple;
#use DBI;
use utf8::all;
use Data::Printer;
#use SQL::Abstract;
#use ORM::Class::DB;
my $p = Person->new(id=>'411302198310203832',name => 'ZengLi8',);

#$p->replace({name=>'Wuweiyi'});
$p->save;


__END__
p $p;
#my $p = Person->new(id=>'411302198310203832',name => 'ZengLi8',);
my $dbix = DBIx::Simple->connect('dbi:SQLite:dbname=test.db','','',{sqlite_unicode =>1, AutoCommit => 1, RaiseError => 1});
my $result = $dbix->select('Person','*',{id=>'411302198310203832'});
my $db = ORM::Class::DB->new(dsn => 'dbi:SQLite:dbname=test.db',
               user => '',
               passwd => '',
               options => {sqlite_unicode =>1, AutoCommit => 1, RaiseError => 1},);

my $res = $db->_select('Person','*',{id=>'411302198310203830'});
p $res;


#p $result->hash;

__END__
my $record = $dbix->table('person')
                  ->insert({
                            id=>'411302198310203835',
                            name => 'ZengLi'}
                          );

#say "Instance record saved!"  if $p->save;
