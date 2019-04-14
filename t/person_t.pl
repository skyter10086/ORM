use Person;
use DBI;
use Data::Printer;

my $lucky = Person->new(
  name => 'ZengLi',
  id => '411302198310203835',
);

print "{\n\t id => ",$lucky->id,"\n";
print "\t name => ", $lucky->name, "\n\}";
print "\nNow checking the attributes...\n";
$lucky->validate_attributes;

if (Person->Ping) {

    print "Table already existed!\n";
    if (Person->Validate_schema) {
        print "Table has good schema.\n";
    } else {
        Person->Drop;
        Person->Construct;
    }
} else {
    Person->Construct;
    print "Table built down!\n";
}
$lucky->save;
print "program have done!\n";





__END__
my $dbh = DBI->connect(
          'dbi:SQLite:dbname=test.db',
          '','',
          {sqlite_unicode =>1, AutoCommit => 1, RaiseError => 1},
          );
my $db_info = $dbh->table_info('','main','%',"TABLE") ||  undef;
my $table_infos =$db_info->fetchall_arrayref;
p $table_infos;
if ( grep { $_->[2] eq Pers  } @$table_infos) {
    print "Find Table!";
		
} else {
    print 0;
}

