/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     | Website:  https://openfoam.org
    \\  /    A nd           | Copyright (C) 2011-2018 OpenFOAM Foundation
     \\/     M anipulation  |
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

    OpenFOAM is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    for more details.

    You should have received a copy of the GNU General Public License
    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.

\*---------------------------------------------------------------------------*/

#ifndef doubleFloat_H
#define doubleFloat_H

#include "label.H"
#include "products.H"

#include <cmath>

#if defined(_WIN32) || defined(MSWIN)
extern "C"
{
    double _j0(double);
    double _j1(double);
    double _jn(int, double);
    double _y0(double);
    double _y1(double);
    double _yn(int, double);
}

// Global Bessel wrappers for Windows
inline double j0(double x) { return ::_j0(x); }
inline double j1(double x) { return ::_j1(x); }
inline double jn(int n, double x) { return ::_jn(n, x); }
inline double y0(double x) { return ::_y0(x); }
inline double y1(double x) { return ::_y1(x); }
inline double yn(int n, double x) { return ::_yn(n, x); }

inline float j0f(float x) { return static_cast<float>(::_j0(static_cast<double>(x))); }
inline float j1f(float x) { return static_cast<float>(::_j1(static_cast<double>(x))); }
inline float jnf(int n, float x) { return static_cast<float>(::_jn(n, static_cast<double>(x))); }
inline float y0f(float x) { return static_cast<float>(::_y0(static_cast<double>(x))); }
inline float y1f(float x) { return static_cast<float>(::_y1(static_cast<double>(x))); }
inline float ynf(int n, float x) { return static_cast<float>(::_yn(n, static_cast<double>(x))); }

inline long double j0l(long double x) { return ::_j0(static_cast<double>(x)); }
inline long double j1l(long double x) { return ::_j1(static_cast<double>(x)); }
inline long double jnl(int n, long double x) { return ::_jn(n, static_cast<double>(x)); }
inline long double y0l(long double x) { return ::_y0(static_cast<double>(x)); }
inline long double y1l(long double x) { return ::_y1(static_cast<double>(x)); }
inline long double ynl(int n, long double x) { return ::_yn(n, static_cast<double>(x)); }
#endif

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

template<class Cmpt>
class typeOfRank<Cmpt, 0>
{
public:

    typedef Cmpt type;
};


template<class Cmpt>
class symmTypeOfRank<Cmpt, 0>
{
public:

    typedef Cmpt type;
};


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

template<class T>
inline bool equal(const T& s1, const T& s2)
{
    return s1 == s2;
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace Foam

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

#endif

// ************************************************************************* //
