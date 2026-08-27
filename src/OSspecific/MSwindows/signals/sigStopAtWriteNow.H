#ifndef sigStopAtWriteNow_H
#define sigStopAtWriteNow_H

namespace Foam
{

class Time;

class sigStopAtWriteNow
{
public:
    sigStopAtWriteNow();
    sigStopAtWriteNow(const bool verbose, const Time& runTime);
    ~sigStopAtWriteNow();

    static void set(const bool verbose = false);
    bool active() const;
};

} // End namespace Foam

#endif
