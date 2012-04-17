use File::Basename qw(dirname);
use File::Spec;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');

use GBV::App::Itemids;

# TODO: if GBV::App::Itemids derives from Dancer:
## use Dancer;
## dance;

# otherwise:
my $app = GBV::App::Itemids->new;

$app;
