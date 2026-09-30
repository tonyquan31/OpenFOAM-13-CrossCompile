#undef DebugInfo

#include "OSspecific.H"
#include "MSwindows.H"
#include "foamVersion.H"
#include "fileName.H"
#include "fileStat.H"
#include "timer.H"
#include "IFstream.H"
#include "DynamicList.H"
#include "HashSet.H"
#include "IOstreams.H"
#include "Pstream.H"
#include "error.H"

#undef DebugInfo

#include <fstream>
#include <cstdlib>
#include <cctype>
#include <cstdio>

#define WIN32_LEAN_AND_MEAN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#define NOGDI
#define NOUSER
#define NONLS
#include <windows.h>
#include <direct.h>
#include <io.h>
#include <process.h>
#include <psapi.h>
#include <winsock2.h>
#include <sys/stat.h>

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

namespace Foam
{
    defineTypeNameAndDebug(MSwindows, 0);
}

pid_t Foam::pid()
{
    return static_cast<pid_t>(::GetCurrentProcessId());
}

pid_t Foam::ppid()
{
    return 0;
}

pid_t Foam::pgid()
{
    return static_cast<pid_t>(::GetCurrentProcessId());
}

bool Foam::env(const word& envName)
{
    if (::GetEnvironmentVariableA(envName.c_str(), nullptr, 0) > 0)
    {
        return true;
    }
    return ::getenv(envName.c_str()) != nullptr;
}

Foam::string Foam::getEnv(const word& envName)
{
    char buffer[32767];
    DWORD len = ::GetEnvironmentVariableA(envName.c_str(), buffer, sizeof(buffer));
    if (len > 0 && len < sizeof(buffer))
    {
        return string(buffer);
    }
    char* env = ::getenv(envName.c_str());
    if (env)
    {
        return string(env);
    }
    return string();
}

bool Foam::setEnv(const word& name, const std::string& value, const bool overwrite)
{
    if (!overwrite && Foam::env(name))
    {
        return false;
    }
    std::string entry = name + "=" + value;
    ::_putenv(entry.c_str());
    return ::SetEnvironmentVariableA(name.c_str(), value.c_str()) != 0;
}

Foam::string Foam::hostName(const bool)
{
    char name[MAX_COMPUTERNAME_LENGTH + 1];
    DWORD size = sizeof(name);
    if (::GetComputerNameA(name, &size))
    {
        return string(name);
    }
    return string("localhost");
}

Foam::string Foam::domainName()
{
    return string();
}

Foam::string Foam::userName()
{
    char name[256];
    DWORD size = sizeof(name);
    if (::GetUserNameA(name, &size))
    {
        return string(name);
    }
    return getEnv("USERNAME");
}

bool Foam::isAdministrator()
{
    return false;
}

Foam::fileName Foam::home()
{
    string userProfile = getEnv("USERPROFILE");
    if (!userProfile.empty())
    {
        for (auto& c : userProfile ) { if (c == '\\') c = '/'; }
        fileName h(userProfile);
        h.clean();
        return h;
    }
    string homeDrive = getEnv("HOMEDRIVE");
    string homePath = getEnv("HOMEPATH");
    if (!homeDrive.empty() && !homePath.empty())
    {
        fileName h(homeDrive + homePath);
        h.clean();
        return h;
    }
    return fileName("C:/");
}

Foam::fileName Foam::home(const string&)
{
    return home();
}

Foam::fileName Foam::cwd()
{
    char buffer[MAX_PATH];
    if (::_getcwd(buffer, sizeof(buffer)) != nullptr)
    {
        for (char* p = buffer; *p; ++p)
        {
            if (*p == '\\') *p = '/';
        }
        fileName dir(buffer);
        dir.clean();
        return dir;
    }
    return fileName();
}

bool Foam::chDir(const fileName& dir)
{
    return ::_chdir(dir.c_str()) == 0;
}

bool Foam::mkDir(const fileName& pathName, mode_t)
{
    if (pathName.empty()) return false;
    if (Foam::isDir(pathName)) return true;

    fileName parent = pathName.path();
    if (!parent.empty() && parent != pathName && !Foam::isDir(parent))
    {
        Foam::mkDir(parent);
    }
    return ::_mkdir(pathName.c_str()) == 0 || Foam::isDir(pathName);
}

bool Foam::chMod(const fileName&, const mode_t)
{
    return true;
}

mode_t Foam::mode(const fileName& name, const bool, const bool)
{
    struct _stat64 buf;
    if (::_stat64(name.c_str(), &buf) == 0)
    {
        return buf.st_mode;
    }
    return 0;
}

Foam::fileType Foam::type(const fileName& name, const bool, const bool)
{
    DWORD attr = ::GetFileAttributesA(name.c_str());
    if (attr == INVALID_FILE_ATTRIBUTES)
    {
        return fileType::undefined;
    }
    if (attr & FILE_ATTRIBUTE_DIRECTORY)
    {
        return fileType::directory;
    }
    return fileType::file;
}

bool Foam::exists(const fileName& name, const bool, const bool)
{
    return ::GetFileAttributesA(name.c_str()) != INVALID_FILE_ATTRIBUTES;
}

bool Foam::isDir(const fileName& name, const bool)
{
    DWORD attr = ::GetFileAttributesA(name.c_str());
    return (attr != INVALID_FILE_ATTRIBUTES) && (attr & FILE_ATTRIBUTE_DIRECTORY);
}

bool Foam::isFile(const fileName& name, const bool, const bool)
{
    DWORD attr = ::GetFileAttributesA(name.c_str());
    return (attr != INVALID_FILE_ATTRIBUTES) && !(attr & FILE_ATTRIBUTE_DIRECTORY);
}

off_t Foam::fileSize(const fileName& name, const bool, const bool)
{
    struct _stat64 buf;
    if (::_stat64(name.c_str(), &buf) == 0)
    {
        return buf.st_size;
    }
    return 0;
}

time_t Foam::lastModified(const fileName& name, const bool, const bool)
{
    struct _stat64 buf;
    if (::_stat64(name.c_str(), &buf) == 0)
    {
        return buf.st_mtime;
    }
    return 0;
}

double Foam::highResLastModified(const fileName& name, const bool checkVariants, const bool followLink)
{
    return static_cast<double>(lastModified(name, checkVariants, followLink));
}

Foam::fileNameList Foam::readDir(const fileName& directory, const fileType type, const bool, const bool)
{
    fileNameList names;
    string searchPattern = directory + "/*";
    WIN32_FIND_DATAA findData;
    HANDLE hFind = ::FindFirstFileA(searchPattern.c_str(), &findData);

    if (hFind != INVALID_HANDLE_VALUE)
    {
        do
        {
            const char* fn = findData.cFileName;
            if (strcmp(fn, ".") != 0 && strcmp(fn, "..") != 0)
            {
                bool isDirectory = (findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY);
                if (type == fileType::undefined ||
                   (type == fileType::directory && isDirectory) ||
                   (type == fileType::file && !isDirectory))
                {
                    names.append(fileName(fn));
                }
            }
        } while (::FindNextFileA(hFind, &findData));
        ::FindClose(hFind);
    }
    return names;
}

bool Foam::cp(const fileName& src, const fileName& dst, const bool)
{
    return ::CopyFileA(src.c_str(), dst.c_str(), FALSE) != 0;
}

bool Foam::ln(const fileName& src, const fileName& dst)
{
    return Foam::cp(src, dst);
}

bool Foam::mv(const fileName& src, const fileName& dst, const bool)
{
    return ::MoveFileExA(src.c_str(), dst.c_str(), MOVEFILE_REPLACE_EXISTING) != 0;
}

bool Foam::mvBak(const fileName& src, const std::string& ext)
{
    if (Foam::exists(src))
    {
        const fileName dst = src + "." + ext;
        return Foam::mv(src, dst);
    }
    return false;
}

bool Foam::rm(const fileName& file)
{
    return ::DeleteFileA(file.c_str()) != 0;
}

bool Foam::rmDir(const fileName& directory)
{
    return ::RemoveDirectoryA(directory.c_str()) != 0;
}

unsigned int Foam::sleep(const unsigned int s)
{
    ::Sleep(s * 1000);
    return 0;
}

void Foam::fdClose(const int fd)
{
    ::_close(fd);
}

bool Foam::ping(const string&, const label, const label)
{
    return true;
}

bool Foam::ping(const string&, const label)
{
    return true;
}

int Foam::system(const std::string& command)
{
    return ::system(command.c_str());
}

void* Foam::dlOpen(const fileName& libName, const bool)
{
    return reinterpret_cast<void*>(::LoadLibraryExA(libName.c_str(), NULL, LOAD_WITH_ALTERED_SEARCH_PATH));
}

bool Foam::dlClose(void* handle)
{
    return ::FreeLibrary(reinterpret_cast<HMODULE>(handle)) != 0;
}

void* Foam::dlSym(void* handle, const std::string& symbol)
{
    return reinterpret_cast<void*>(::GetProcAddress(reinterpret_cast<HMODULE>(handle), symbol.c_str()));
}

bool Foam::dlSymFound(void* handle, const std::string& symbol)
{
    return dlSym(handle, symbol) != nullptr;
}

Foam::fileNameList Foam::dlLoaded()
{
    return fileNameList();
}
