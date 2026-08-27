#ifndef sigInt_H
#define sigInt_H

namespace Foam
{

class sigInt
{
public:
    sigInt();
    ~sigInt();
    void set(const bool verbose = false);
};

} // End namespace Foam

#endif
