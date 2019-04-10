package ORM::Role::Model;

use utf8::all;
use Moose::Role;
use ORM::Class::DB;
use ORM::Class::Field;
use Data::Printer;

requires 'Model','Db';

=pod

sub Model {
  my $model = {
      'name' => Field->new(
                   type => 'VARCHAR',
                   length => 20,),
       'id' => Field->new(
                   type => 'VARCHAR',
                   length => 18,),
       'pk' => [qw/ id /],
   };

sub Db {
  my $db = ORM::Class:DB->new(
               dsn => 'dbi:Pg:dbname=MyDB',
               user => 'zl',
               passwd => 'zl123456',
               options => {pg_enable_utf8 => 1},)
     or die "Can't set your DB class!";
}

=cut

# Class methods  { $class->? }

sub Schema {
	my $class = shift;
	my $model = $class->Model;
	my $table = ref $class;
	#p $table;
	my $schema = "CREATE TABLE $table \( ";
	my $pk = $model->{pk};
	my $pk_str = join ', ', @$pk;
	delete $model->{pk};
	#p $model;
	my @sentences = ();
	
	while (my ($k,$v) = each %{$model}) {
		#print "dump \$k : ";
		#p $k;
		#print "dump \$v : ";
		#p $v;
      my $sentence = '';
	  my $type = $v->type;
	  my $len = $v->length;
	  $sentence .= "$k $type\($len\) ";
	  $sentence .= " NOT NULL " if $v->is_null;
	  $sentence .= " UNIQUE " if $v->is_unq;
	  
	  #p $sentence;
	  push @sentences, $sentence;
	  
  }
  #p @sentences;
  my $string = join ',' , @sentences;
  $schema .= $string;
  if ($pk) {
      $schema .= ",\nCONSTRAINT pk_$table PRIMARY KEY \($pk_str\) )" ;}
  else {
	  $schema .= "\n)"  
  }
	  
	
}

sub Create {
  my $class = shift;
  my $table = ref $class;
  my $dbh = $class->Db()->dbh; # return the DBI dbh
  my $schema = $class->Schema();
  #p $schema;
  $dbh->do($schema) or die "Create table $table Failed!";
  	
}

sub Ping {...}

sub Validate_attributes {...}

sub Validate_schema {...}

sub Filter {...}

sub Clear_all {
	my $class = shift;
	my $table = ref $class;
	my $sql = 'DELETE * FROM '. $table . ';';
	my $dbh = $class->Db->dbh;
	my $rv = $dbh->do($sql);
	
}

sub Drop { 
    my $class = shift;
    my $table = ref $class;
    my $sql = 'DROP TABLE '. $table .';';
    my $dbh = $class->Db->dbh;
    my $rv = $dbh->do($sql);	
}

sub Import_csv {...}


# Instance methods { $self->? }

sub _hash {
    my $self  = shift;
    my $meta = $self->meta;
    my %obj_hash;
    for my $attr ($meta->get_all_attributes) {
        my $reader = $attr->get_read_method;
        my $attr_val = $self->$reader;
        $obj_hash{$attr->name} = $attr_val;
	    } 
      return \%obj_hash ;
}

sub _pk {
    my $self = shift;
    my $pk_keys = $self->Model->{pk} || [];
	my $pk_hash = {};
	foreach my $key (@{$pk_keys}) {
	    $pk_hash->{$key} = $self->$key;    
	}
    return $pk_hash;	
}

sub save {
    my $self = shift;
    my $fieldvals = $self->_hash;
    my $table = ref $self;
    
    my $db = $self->Db;
    my $rv = $db->_insert($table, $fieldvals);
  
}

sub clear {
	my $self = shift;
	my $table = ref $self;
	my $db = $self->Db;
	my $pk_keys = $self->Model->{pk} || [];
	my $pk_hash = {};
	foreach my $key (@{$pk_keys}) {
	    $pk_hash->{$key} = $self->$key;    
	}
	if ($pk_hash) {
	    $db->_del($table, $pk_hash);	
	} else {
	    print "Nothing to delete.\n";	
	}
}


1;
