AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Gases extends AR.Pages.Chemistry.Gases
  @Measurements:
    "#{AR.Chemistry.Materials.Elements.Nitrogen.id()}": [
      wavelength: 6328 * AR.Angstrom
      rayleighScatteringCrossSection: 2.24e-31
    ,
      wavelength: 5145 * AR.Angstrom
      rayleighScatteringCrossSection: 5.61e-31
    ,
      wavelength: 4880 * AR.Angstrom
      rayleighScatteringCrossSection: 7.26e-31
    ,
      wavelength: 4579 * AR.Angstrom
      rayleighScatteringCrossSection: 10.38e-31
    ]
    "#{AR.Chemistry.Materials.Elements.Oxygen.id()}": [
      wavelength: 6328 * AR.Angstrom
      rayleighScatteringCrossSection: 2.06e-31
    ,
      wavelength: 5145 * AR.Angstrom
      rayleighScatteringCrossSection: 4.88e-31
    ,
      wavelength: 4880 * AR.Angstrom
      rayleighScatteringCrossSection: 6.5e-31
    ,
      wavelength: 4579 * AR.Angstrom
      rayleighScatteringCrossSection: 8.39e-31
    ]
    "#{AR.Chemistry.Materials.Elements.Helium.id()}": [
      wavelength: 6328 * AR.Angstrom
      rayleighScatteringCrossSection: 0.036e-31
    ,
      wavelength: 5145 * AR.Angstrom
      rayleighScatteringCrossSection: 0.086e-31
    ,
      wavelength: 4880 * AR.Angstrom
      rayleighScatteringCrossSection: 0.115e-31
    ,
      wavelength: 4579 * AR.Angstrom
      rayleighScatteringCrossSection: 0.15e-31
    ]
    "#{AR.Chemistry.Materials.Elements.Argon.id()}": [
      wavelength: 6328 * AR.Angstrom
      rayleighScatteringCrossSection: 2.086e-31
    ,
      wavelength: 5145 * AR.Angstrom
      rayleighScatteringCrossSection: 5.46e-31
    ,
      wavelength: 4880 * AR.Angstrom
      rayleighScatteringCrossSection: 7.24e-31
    ,
      wavelength: 4579 * AR.Angstrom
      rayleighScatteringCrossSection: 10.13e-31
    ]
    "#{AR.Chemistry.Materials.Elements.CarbonDioxide.id()}": [
      wavelength: 6328 * AR.Angstrom
      rayleighScatteringCrossSection: 7.28e-31
    ,
      wavelength: 5145 * AR.Angstrom
      rayleighScatteringCrossSection: 17.25e-31
    ,
      wavelength: 4880 * AR.Angstrom
      rayleighScatteringCrossSection: 23.00e-31
    ,
      wavelength: 4579 * AR.Angstrom
      rayleighScatteringCrossSection: 29.60e-31
    ]
    "#{AR.Chemistry.Materials.Mixtures.Air.DryDirect.id()}": [
      wavelength: 400e-9
      kingCorrectionFactor: 1.051
      refractiveIndex: 1 + 2.8275e-4
      rayleighScatteringCrossSection: 1.673e-30
    ,
      wavelength: 500e-9
      kingCorrectionFactor: 1.049
      refractiveIndex: 1 + 2.7896e-4
      rayleighScatteringCrossSection: 6.656e-31
    ,
      wavelength: 600e-9
      kingCorrectionFactor: 1.048
      refractiveIndex: 1 + 2.7697e-4
      rayleighScatteringCrossSection: 3.161e-31
    ,
      wavelength: 700e-9
      kingCorrectionFactor: 1.048
      refractiveIndex: 1 + 2.7579e-4
      rayleighScatteringCrossSection: 1.692e-31
    ]

  @Measurements[AR.Chemistry.Materials.Mixtures.Air.DryMixture.id()] = @Measurements[AR.Chemistry.Materials.Mixtures.Air.DryDirect.id()]
