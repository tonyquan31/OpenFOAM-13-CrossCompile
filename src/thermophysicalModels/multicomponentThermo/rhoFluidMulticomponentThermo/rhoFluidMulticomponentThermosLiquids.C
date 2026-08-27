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
#include "valueMulticomponentMixture.H"
#include "singleComponentMixture.H"
#include "forLiquids.H"
#include "forTabulated.H"
#include "makeFluidMulticomponentThermo.H"
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
namespace Foam
{
    forCoeffLiquids
    (
        makeFluidMulticomponentThermos,
        rhoFluidThermo,
        rhoFluidMulticomponentThermo,
        coefficientMulticomponentMixture
    );
    forLiquids
    (
        makeFluidMulticomponentThermos,
        rhoFluidThermo,
        rhoFluidMulticomponentThermo,
        valueMulticomponentMixture
    );
    forLiquids
    (
        makeFluidMulticomponentThermo,
        rhoFluidMulticomponentThermo,
        singleComponentMixture
    );
    forTabulated
    (
        makeFluidMulticomponentThermos,
        rhoFluidThermo,
        rhoFluidMulticomponentThermo,
        valueMulticomponentMixture
    );
    forTabulated
    (
        makeFluidMulticomponentThermo,
        rhoFluidMulticomponentThermo,
        singleComponentMixture
    );
}
// ************************************************************************* //
