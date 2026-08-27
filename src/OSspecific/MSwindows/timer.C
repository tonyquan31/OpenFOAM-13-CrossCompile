#include "timer.H"
#include "error.H"

namespace Foam
{
defineTypeNameAndDebug(timer, 0);
}

Foam::timer::timer(const unsigned int newTimeOut)
:
    newTimeOut_(newTimeOut)
{}

Foam::timer::~timer()
{}
