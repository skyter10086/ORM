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
	my $table =  $class;
	#p $table;
	my $schema = "CREATE TABLE $table \( ";
	my $pk = $model->{pk};
	my $pk_str = join ', ', @$pk;
	delete $model->{pk};
	#p $model;
	my @sentences = ();
	
	#while (my ($k,$v) = each %{$model}) {
		#print "dump \$k : ";
		#p $k;
		#print "dump \$v : ";
		#p $v;
      for my $k (sort keys %{$model}) {
      my $v = $model->{$k};
      my $sentence = '';
	  my $type = $v->type;
	  my $len = $v->len;
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
  return $schema;  
	
}

sub Construct {
  my $class = shift;
  my $table = ref $class;
  my $dbh = $class->Db()->dbh; # return the DBI dbh
  my $schema = $class->Schema();
  #p $dbh;
  #p $schema;
  return my $rv = $dbh->do($schema) or croak "Construct table $table Failed!";
  	
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
    my $db_info = $dbh->table_info('','main','%',"TABLE") ||  
                      die "Can not get the info of DB!\n";
my $table_infos =$db_info->fetchall_arrayref;

if ( grep { $_->[2] eq $class  } @$table_infos) {
    print "Find Table!\n";
    
    return 1;
		
} else {
    print "You should check the DB's table!\n";
    return ;
}
}

sub validate_attributes {
    my $self = shift;
    my $hash = $self->_hash;
    #p $hash;
    for (my ($k, $v) = each %{$hash}) {
        next if $k eq 'pk';
        my $field = $self->Model->{$k};
        my $bool = $field->validate($self->$k) || return;
    }
    print "All attributes validate successed!\n";
    return 1;

}

sub Validate_schema {
    my $class = shift;
    #p $class;
    my $schema = $class->Schema ;
    $schema =~ s/\s+//gx;
    
    my $dbh = $class->Db->dbh;
    my $db_info = $dbh->table_info('','main','%',"TABLE") ||  
                      die "Can not get the info of DB!\n";
    my $table_infos =$db_info->fetchall_arrayref;
    my @info = grep { $_->[2] eq $class} @$table_infos;
    #p @info;
    my $table_schema = $info[0][5] ;
    $table_schema =~ s/\s+//gx;
    #p $table_schema;
    #p $schema;
    if ($table_schema eq $schema) {
        print "Table schema validate successed!\n";
        return 1;
    } else {
        print "Table schema validate failed!\n";
        return;
    } 

}
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

sub ClearAll {
	my $class = shift;
	
	#p $class;
    my $dbh = $class->Db->dbh;
	my $stmt = 'DELETE FROM '.$class;
	#p $dbh;
	#p $stmt;
	return my $rv = $dbh->do($stmt);
	
}

sub Drop { 
    my $class = shift;
    my $table =  $class;
    my $sql = 'DROP TABLE '. $table ;
    my $dbh = $class->Db->dbh;
    return my $rv = $dbh->do($sql);	
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
	    croak "To save a object already exists, please call Get(\$pk) on class, and then call replace(\$fieldvals_hash).";
	}

    return my $result = $db->_insert($table, $fieldvals);
  
}

sub replace {
    my $self = shift;
    my $fields = shift;
    my $where = $self->_pk;
    my $db = $self->Db;
    my $table = ref $self;
    return my $result = $db->_update($table, $fields, $where);
	
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
	    return my $result = $db->_del($table, $pk_hash);	
	} else {
	    print "Nothing to delete.\n";
        return;		
	}
}


1;
