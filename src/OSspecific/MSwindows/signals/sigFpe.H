#ifndef sigFpe_H
#define sigFpe_H

#include "UList.H"
#include "scalar.H"

namespace Foam
{

class sigFpe
{
public:
    sigFpe();
    ~sigFpe();

    void set(const bool verbose = false);
    void unset(const bool verbose = false);

    static bool mallocNanActive_;
    static void fillNan(UList<scalar>&);
};

} // End namespace Foam

#endif
