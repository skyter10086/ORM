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
    
has 'len' => (
    is => 'ro',
    isa => 'Num',
    );
    
sub validate {
	my $self = shift;
	my $value = shift;
    my $type = $self->type;
    my $length = $self->len;
	sub validate_INTEGER { 
           my $val = shift;
           my $eq_val = $val + 0;
           if ($val == int($eq_val)) {
              return 1;
           } else {
              return;
           }
           
        }
	sub validate_VARCHAR {
            my $val = shift;
            my $leng = shift;
            my $char_len = length $val;
            if ($char_len <= $leng) {
                return 1;
            } else { return ;}
        }
	sub validate_DATE {...}
	sub validate_BOOL {
        my $bool = shift;
        if ($bool) {
            return 1;
        } else {
            return;
        }
    }
	sub validate_TIMESTAMP {...}
	sub validate_AUTOINCR {...}
	
	my $call_validate = {
		'INTEGER' =>sub {
                        my $val = shift;
                        my $leng = shift;
                        my $eq_val = $val + 0;
                        if ($val == int($eq_val) && $val <= 10 ** $leng) {
                            return 1;
                        } else {
                            return;
                        }
                    },
		'VARCHAR' => \&validate_VARCHAR,
		'DATE' => \&validate_DATE,
		'BOOL' => \&validate_BOOL,
		'TIMESTAMP' => \&validate_TIMESTAMP,
		'AUTOINCR' => \&validate_AUTOINCR,
	};
	return $call_validate->{$self->type}($value,$length);
}

	
1;
