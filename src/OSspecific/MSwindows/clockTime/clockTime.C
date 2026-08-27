#include "clockTime.H"
#include <sys/time.h>

void Foam::clockTime::getTime(timeType& t)
{
    gettimeofday(&t, 0);
}

double Foam::clockTime::timeDifference(const timeType& beg, const timeType& end)
{
    return end.tv_sec - beg.tv_sec + 1e-6*(end.tv_usec - beg.tv_usec);
}

Foam::clockTime::clockTime()
{
    getTime(startTime_);
    lastTime_ = startTime_;
    newTime_ = startTime_;
}

double Foam::clockTime::elapsedTime() const
{
    getTime(newTime_);
    return timeDifference(startTime_, newTime_);
}

double Foam::clockTime::timeIncrement() const
{
    lastTime_ = newTime_;
    getTime(newTime_);
    return timeDifference(lastTime_, newTime_);
}
