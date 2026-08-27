#ifndef clockTime_H
#define clockTime_H

#include <sys/types.h>
#include <sys/time.h>

namespace Foam
{

class clockTime
{
    typedef struct ::timeval timeType;

    timeType startTime_;
    mutable timeType lastTime_;
    mutable timeType newTime_;

    static void getTime(timeType&);
    static double timeDifference(const timeType& beg, const timeType& end);

public:
    clockTime();

    double elapsedTime() const;
    double timeIncrement() const;
};

} // End namespace Foam

#endif
