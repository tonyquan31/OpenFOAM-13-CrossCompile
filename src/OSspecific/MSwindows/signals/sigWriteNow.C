#include "sigWriteNow.H"

namespace Foam
{

sigWriteNow::sigWriteNow()
{}

sigWriteNow::sigWriteNow(const bool, Time&)
{}

sigWriteNow::~sigWriteNow()
{}

void sigWriteNow::set(const bool)
{}

bool sigWriteNow::active() const
{
    return false;
}

} // End namespace Foam
