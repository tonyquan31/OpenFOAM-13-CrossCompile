#undef DebugInfo

#include "memInfo.H"
#include "OSspecific.H"

#undef DebugInfo

#define WIN32_LEAN_AND_MEAN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#define NOGDI
#define NOUSER
#define NONLS
#include <windows.h>
#include <psapi.h>

#undef min
#undef max
#undef ERROR
#undef CONST
#undef small
#undef Yield
#undef DebugInfo
#undef GetMessage
#undef GetUserName
#undef GetClassName
#undef DrawText
#undef DeleteFile
#undef CreateDirectory
#undef SetEnvironmentVariable
#undef GetEnvironmentVariable
#undef MoveFile
#undef CopyFile

Foam::memInfo::memInfo()
:
    peak_(-1),
    size_(-1),
    rss_(-1)
{
    update();
}

Foam::memInfo::~memInfo()
{}

const Foam::memInfo& Foam::memInfo::update()
{
    PROCESS_MEMORY_COUNTERS_EX pmc;
    if (GetProcessMemoryInfo(GetCurrentProcess(), reinterpret_cast<PROCESS_MEMORY_COUNTERS*>(&pmc), sizeof(pmc)))
    {
        peak_ = static_cast<int>(pmc.PeakWorkingSetSize / 1024);
        size_ = static_cast<int>(pmc.PrivateUsage / 1024);
        rss_  = static_cast<int>(pmc.WorkingSetSize / 1024);
    }
    else
    {
        peak_ = size_ = rss_ = -1;
    }
    return *this;
}

bool Foam::memInfo::valid() const
{
    return peak_ != -1;
}

Foam::Istream& Foam::operator>>(Istream& is, memInfo& m)
{
    is.readBegin("memInfo");
    is >> m.peak_ >> m.size_ >> m.rss_;
    is.readEnd("memInfo");
    is.check("Foam::Istream& Foam::operator>>(Foam::Istream&, Foam::memInfo&)");
    return is;
}

Foam::Ostream& Foam::operator<<(Ostream& os, const memInfo& m)
{
    os << token::BEGIN_LIST
       << m.peak_ << token::SPACE << m.size_ << token::SPACE << m.rss_
       << token::END_LIST;
    os.check("Foam::Ostream& Foam::operator<<(Foam::Ostream&, const Foam::memInfo&)");
    return os;
}
