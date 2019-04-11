package ORM::Class::DB;

use Moose;
use DBIx::Simple;
use DBI;
use Data::Printer;
use SQL::Abstract;
use utf8::all;
use namespace::autoclean;

has 'dsn' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'user' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'passwd' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'options' => (
  is => 'rw',
  isa => 'HashRef',
  required => 1,
  );
  
sub connect {
	my $self = shift;
	my $dbs = DBIx::Simple->connect(
	            $self->dsn,
	            $self->user,
	            $self->passwd,
	            $self->options,)
	  or die DBIx::Simple->error;
}

sub dbh {
	my $self = shift;
	my $dbh = DBI->connect(
	              $self->dsn,
	              $self->user,
	              $self->passwd,
	              $self->options,)
	   or die DBI->err;
}

sub dbix {
	my $self = shift;
	my $dbix = DBIx::Simple->connect(
	                 $self->dsn,
	                 $self->user,
	                 $self->passwd,
	                 $self->options,)
	
	 or die DBIx::Simple->error;
	   $dbix->abstract = SQL::Abstract->new(logic => 'and');

	   return $dbix;
}

sub _insert {
	my ($class, $table, $data) = @_;
	my $dbix = $class->dbix;
	my $result = $dbix->insert($table, $data);
}

sub _update {
	my ($class, $table,  $fieldvals, $where) = @_;
	my $dbix = $class->dbix;
	my $result = $dbix->update($table, $fieldvals, $where);
}

sub _select {
	my ($self, $table, $fields, $where ) = @_;
	my $dbix = $self->dbix;
	#p $dbix;
	#p $table;
	#p $fields;
	#p $where;
	my $result = $dbix->select($table, $fields, $where);
	return $result->hash;
}

sub _del {
	my ($class, $table, $where) = @_;
	my $dbix = $class->dbix;
	my $result = $dbix->delete($table, $where);
}
	

1;
