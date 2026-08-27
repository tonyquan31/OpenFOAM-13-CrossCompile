#include "regExp.H"
#include "string.H"
#include "List.H"
#include "error.H"

template<class StringType>
bool Foam::regExp::matchGrouping
(
    const std::string& str,
    List<StringType>& groups
) const
{
    if (preg_ && str.size())
    {
        std::smatch m;
        if (std::regex_match(str, m, *preg_))
        {
            groups.setSize(m.size() > 1 ? m.size() - 1 : 0);
            for (size_t i = 1; i < m.size(); ++i)
            {
                groups[i - 1] = m[i].str();
            }
            return true;
        }
    }

    groups.clear();
    return false;
}

Foam::regExp::regExp()
:
    preg_(nullptr),
    ngroups_(0)
{}

Foam::regExp::regExp(const char* pattern, const bool ignoreCase)
:
    preg_(nullptr),
    ngroups_(0)
{
    set(pattern, ignoreCase);
}

Foam::regExp::regExp(const std::string& pattern, const bool ignoreCase)
:
    preg_(nullptr),
    ngroups_(0)
{
    set(pattern.c_str(), ignoreCase);
}

void Foam::regExp::set(const char* pattern, const bool ignoreCase) const
{
    clear();

    if (pattern && *pattern)
    {
        std::regex_constants::syntax_option_type flags = std::regex_constants::extended;
        if (ignoreCase)
        {
            flags |= std::regex_constants::icase;
        }

        const char* pat = pattern;
        if (!strncmp(pattern, "(?i)", 4))
        {
            flags |= std::regex_constants::icase;
            pat += 4;
            if (!*pat)
            {
                return;
            }
        }

        try
        {
            preg_ = std::make_shared<std::regex>(pat, flags);
            ngroups_ = preg_->mark_count();
        }
        catch (const std::regex_error& e)
        {
            FatalErrorInFunction
                << "Failed to compile regular expression '" << pattern << "'"
                << nl << e.what()
                << exit(FatalError);
        }
    }
}

void Foam::regExp::set(const std::string& pattern, const bool ignoreCase) const
{
    return set(pattern.c_str(), ignoreCase);
}

bool Foam::regExp::clear() const
{
    if (preg_)
    {
        preg_.reset();
        ngroups_ = 0;
        return true;
    }
    return false;
}

std::string::size_type Foam::regExp::find(const std::string& str) const
{
    if (preg_ && str.size())
    {
        std::smatch m;
        if (std::regex_search(str, m, *preg_))
        {
            return m.position(0);
        }
    }
    return string::npos;
}

bool Foam::regExp::match(const std::string& str) const
{
    if (preg_ && str.size())
    {
        return std::regex_match(str, *preg_);
    }
    return false;
}

bool Foam::regExp::match
(
    const std::string& str,
    List<std::string>& groups
) const
{
    return matchGrouping(str, groups);
}

bool Foam::regExp::match
(
    const std::string& str,
    List<Foam::string>& groups
) const
{
    return matchGrouping(str, groups);
}

void Foam::regExp::operator=(const char* pat)
{
    set(pat);
}

void Foam::regExp::operator=(const std::string& pat)
{
    set(pat);
}
