#ifndef sigQuit_H
#define sigQuit_H

namespace Foam
{

class sigQuit
{
public:
    sigQuit();
    ~sigQuit();
    void set(const bool verbose = false);
};

} // End namespace Foam

#endif
