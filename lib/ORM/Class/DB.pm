package ORM::Class::DB;

use Moose;
use DBIx::Simple;
use DBI;
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
	my $class = shift;
	my $dbix = DBIx::Simple->new($class->dbh) 
	   or die DBIx::Simple->error;
	   $dbix->abstract = SQL::Abstract->new(logic => 'and');
	   return $dbix;
}

sub _insert {
	my ($class, $table, $data) = @_;
	my $dbix = $class->dbix;
	my $record = $dbix->insert($table, $data);
}

sub _update {
	my ($class, $table,  $fieldvals, $where) = @_;
	my $dbix = $class->dbix;
	my $record_ = $dbix->($table, $fieldvals, $where);
}

sub _query {
	my ($class, $table, $fields, $where, $order) = @_;
	my $dbix = $class->dbix;
	my $record_ = $dbix->select($table, $fields, $where, $order);
}

sub _del {
	my ($class, $table, $where) = @_;
	my $dbix = $class->dbix;
	my $deled = $dbix->delete($table,$where);
}
	

1;
