#include "sigFpe.H"
#include "error.H"
#include <limits>

namespace Foam
{

bool sigFpe::mallocNanActive_ = false;

void sigFpe::fillNan(UList<scalar>& lst)
{
    lst = std::numeric_limits<scalar>::signaling_NaN();
}

sigFpe::sigFpe()
{}

sigFpe::~sigFpe()
{}

void sigFpe::set(const bool)
{}

void sigFpe::unset(const bool)
{}

} // End namespace Foam
