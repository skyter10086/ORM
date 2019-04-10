package ORM::Class::Field;

use Moose;

has 'type' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    );

has 'is_null' => (
    is => 'ro',
    isa => 'Bool',
    default => undef,
    );
    
has 'is_unq' => (
    is => 'ro',
    isa => 'Bool',
    default => undef,
    );
    
has 'length' => (
    is => 'ro',
    isa => 'Num',
    );
    
sub validate {
	my $self = shift;
	my $value = shift;
	sub validate_INTEGER { ... }
	sub validate_VARCHAR {...}
	sub validate_DATE {...}
	sub validate_BOOL {...}
	sub validate_TIMESTAMP {...}
	sub validate_AUTOINCR {...}
	
	my $call_validate = {
		'INTEGER' => &validate_INTEGER,
		'VARCHAR' => &validate_VARCHAR,
		'DATE' => &validate_DATE,
		'BOOL' => &validate_BOOL,
		'TIMESTAMP' => &validate_TIMESTAMP,
		'AUTOINCR' => &validate_AUTOINCR,
	};
	return $call_validate->{$self->type}($value);
}

	
1;
