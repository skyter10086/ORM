package ORM::Role::Model;

use utf8::all;
use Moose::Role;
use ORM::Class::DB;
use ORM::Class::Field;
use Data::Printer;
use DBIx::Simple;
use DBI;
use Carp;

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
	my $schema = "Construct TABLE $table \( ";
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

sub Construct {
  my $class = shift;
  my $table = ref $class;
  my $dbh = $class->Db()->dbh; # return the DBI dbh
  my $schema = $class->Schema();
  #p $schema;
  $dbh->do($schema) or die "Construct table $table Failed!";
  	
}



=pod
sub BUILD {
     my $self = shift;
     my $pk  = $self->_pk;
    if ( $self->Get($pk) ) {
        warn "Record already exists!";
        return $self->Get($pk);
    } else {
	    return 	$self;
	}
}	
=cut

sub Ping {
    my $class = shift;
    my $dbh = $class->Db->dbh;
    my @tab_names = my @table_names = $dbh->tables('','main',$class,"TABLE") || return undef;
    if ( grep { qr/."$class"/  } @table_names) {
                $class->Validate_schema;
		
	} else {
		return ;
	}
    
}

sub validate_attributes {
    my $self = shift;
    my $hash = $self->_hash;
    for my ($k, $v) (each %{$hash}) {
        next if $k eq 'pk';
        my $field = $self->Model->{$k};
        my $bool = $field->validate($self->$k) || {print "$k attributes validate failed!\n"; return;};
    }
    print "All attributes validate successed!\n";
    return 1;

}

sub Validate_schema {...}
=pod
sub Fetch {
    my $class = shift;
    my $fields = shift;
    my $where = shift;
    my $table = ref $class;
    my $db = $class->Db;
    my $result =  $db->_select($table, $fields, $where);
    return $class->new($result);
    
}
=cut

sub Get {
    my ($class, $pk_hash) = @_;
    my $table =  $class;
    my $result = $class->Db->_select($table, '*', $pk_hash) || undef;
    #p $pk_hash;
    #p $result;
    if ($result) {
        return $class->new($result);
    } else {
	    return;	
	}
}

sub Clear_all {
	my $class = shift;
	
	#p $class;
    my $dbh = $class->Db->dbh;
	my $stmt = 'DELETE FROM '.$class;
	#p $dbh;
	#p $stmt;
	$dbh->do($stmt);
	
}

sub Drop { 
    my $class = shift;
    my $table =  $class;
    my $sql = 'DROP TABLE '. $table ;
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
    my $pk = $self->_pk;
    #p $pk;
    if ($db->_select($table,'*',$pk)) {
		#print "R\n";
	    die "To save a object already exists, please call Get(\$pk) on class, and then call replace(\$fieldvals_hash).";
	}

    my $result = $db->_insert($table, $fieldvals);
  
}

sub replace {
    my $self = shift;
    my $fields = shift;
    my $where = $self->_pk;
    my $db = $self->Db;
    my $table = ref $self;
    my $result = $db->_update($table, $fields, $where);	
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
	    my $result = $db->_del($table, $pk_hash);	
	} else {
	    print "Nothing to delete.\n";	
	}
}


1;
