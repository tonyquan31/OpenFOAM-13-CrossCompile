#ifndef sigSegv_H
#define sigSegv_H

namespace Foam
{

class sigSegv
{
public:
    sigSegv();
    ~sigSegv();
    void set(const bool verbose = false);
};

} // End namespace Foam

#endif
