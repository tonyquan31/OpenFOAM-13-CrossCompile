#include "sigStopAtWriteNow.H"

namespace Foam
{

sigStopAtWriteNow::sigStopAtWriteNow()
{}

sigStopAtWriteNow::sigStopAtWriteNow(const bool, const Time&)
{}

sigStopAtWriteNow::~sigStopAtWriteNow()
{}

void sigStopAtWriteNow::set(const bool)
{}

bool sigStopAtWriteNow::active() const
{
    return false;
}

} // End namespace Foam
