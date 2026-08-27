#ifndef memInfo_H
#define memInfo_H

#include "OSspecific.H"
#include "MSwindows.H"
#include "IFstream.H"

namespace Foam
{

class memInfo;

Istream& operator>>(Istream&, memInfo&);
Ostream& operator<<(Ostream&, const memInfo&);

class memInfo
{
    int peak_;
    int size_;
    int rss_;

public:
    memInfo();
    ~memInfo();

    const memInfo& update();
    bool valid() const;

    int peak() const { return peak_; }
    int size() const { return size_; }
    int rss()  const { return rss_; }

    friend Istream& operator>>(Istream&, memInfo&);
    friend Ostream& operator<<(Ostream&, const memInfo&);
};

} // End namespace Foam

#endif
