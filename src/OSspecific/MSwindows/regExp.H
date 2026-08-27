#ifndef regExp_H
#define regExp_H

#include <regex>
#include <string>
#include <memory>

namespace Foam
{

class string;
template<class T> class List;

class regExp
{
    // Private Data
        mutable std::shared_ptr<std::regex> preg_;
        mutable unsigned int ngroups_;

    // Private Member Functions
        template<class StringType>
        bool matchGrouping
        (
            const std::string&,
            List<StringType>& groups
        ) const;

public:

    // Static Member Functions
        inline static bool meta(char c)
        {
            return
            (
                (c == '.')
             || (c == '*' || c == '+' || c == '?')
             || (c == '(' || c == ')' || c == '|')
             || (c == '[' || c == ']')
            );
        }

    // Constructors
        regExp();
        regExp(const char*, const bool ignoreCase=false);
        regExp(const std::string&, const bool ignoreCase=false);
        regExp(const regExp&) = default;

    // Destructor
        ~regExp() = default;

    // Member Functions
        inline bool empty() const
        {
            return !preg_;
        }

        inline bool exists() const
        {
            return preg_ ? true : false;
        }

        inline int ngroups() const
        {
            return static_cast<int>(ngroups_);
        }

        void set(const char*, const bool ignoreCase=false) const;
        void set(const std::string&, const bool ignoreCase=false) const;
        bool clear() const;

        std::string::size_type find(const std::string& str) const;
        bool match(const std::string&) const;
        bool match(const std::string&, List<std::string>& groups) const;
        bool match(const std::string&, List<string>& groups) const;

        inline bool search(const std::string& str) const
        {
            return std::string::npos != find(str);
        }

    // Member Operators
        void operator=(const regExp& r)
        {
            preg_ = r.preg_;
            ngroups_ = r.ngroups_;
        }
        void operator=(const char*);
        void operator=(const std::string&);
};

} // End namespace Foam

#endif
