/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
  \\    /   O peration     | Website:  https://openfoam.org
   \\  /    A nd           | Copyright (C) 2012-2023 OpenFOAM Foundation
    \\/     M anipulation  |
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.
\*---------------------------------------------------------------------------*/
#include "rhoFluidMulticomponentThermo.H"
#include "coefficientMulticomponentMixture.H"
#include "coefficientWilkeMulticomponentMixture.H"
#include "singleComponentMixture.H"
#include "forGases.H"
#include "makeFluidMulticomponentThermo.H"
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
namespace Foam
{
    forCoeffGases
    (
        makeFluidMulticomponentThermos,
        rhoFluidThermo,
        rhoFluidMulticomponentThermo,
        coefficientMulticomponentMixture
    );
    forCoeffGases
    (
        makeFluidMulticomponentThermos,
        rhoFluidThermo,
        rhoFluidMulticomponentThermo,
        coefficientWilkeMulticomponentMixture
    );
    forGases
    (
        makeFluidMulticomponentThermo,
        rhoFluidMulticomponentThermo,
        singleComponentMixture
    );
}
// ************************************************************************* //
