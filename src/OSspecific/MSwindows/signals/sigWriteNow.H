#ifndef sigWriteNow_H
#define sigWriteNow_H

namespace Foam
{

class Time;

class sigWriteNow
{
public:
    sigWriteNow();
    sigWriteNow(const bool verbose, Time& runTime);
    ~sigWriteNow();

    static void set(const bool verbose = false);
    bool active() const;
};

} // End namespace Foam

#endif
