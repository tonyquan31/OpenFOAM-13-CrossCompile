#ifndef timer_H
#define timer_H

#include "className.H"

#define timedOut(x) false

namespace Foam
{

class timer
{
    unsigned int newTimeOut_;

public:
    ClassName("timer");

    timer(const unsigned int newTimeOut = 0);
    ~timer();
};

} // End namespace Foam

#endif
