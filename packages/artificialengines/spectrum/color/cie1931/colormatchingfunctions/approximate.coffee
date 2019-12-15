###
  Based on "Simple analytic approximations to the CIE XYZ color matching functions" by
  Chris Wyman, Peter-Pike Sloan, and Peter Shirley (NVIDIA) from
  Journal of Computer Graphics Techniques 2.2 (2013): 1-11.
###

AS = Artificial.Spectrum

class AS.Color.CIE1931.ColorMatchingFunctions.Approximate
  # Wavelength inputs for x, y, and z must be in nanometers.
  @x: (wavelength) ->
    t1 = (wavelength - 442.0) * (if wavelength < 442.0 then 0.0624 else 0.0374)
    t2 = (wavelength - 599.8) * (if wavelength < 599.8 then 0.0264 else 0.0323)
    t3 = (wavelength - 501.1) * (if wavelength < 501.1 then 0.0490 else 0.0382)
    
    0.362 * Math.exp(-0.5 * t1 * t1) + 1.056 * Math.exp(-0.5 * t2 * t2) - 0.065 * Math.exp(-0.5 * t3 * t3)

  @y: (wavelength) ->
    t1 = (wavelength - 568.8) * (if wavelength < 568.8 then 0.0213 else 0.0247)
    t2 = (wavelength - 530.9) * (if wavelength < 530.9 then 0.0613 else 0.0322)
    
    0.821 * Math.exp(-0.5 * t1 * t1) + 0.286 * Math.exp(-0.5 * t2 * t2)
  
  @z: (wavelength) ->
    t1 = (wavelength - 437.0) * (if wavelength < 437.0 then 0.0845 else 0.0278)
    t2 = (wavelength - 459.0) * (if wavelength < 459.0 then 0.0385 else 0.0725)

    1.217 * Math.exp(-0.5 * t1 * t1) + 0.681 * Math.exp(-0.5 * t2 * t2)
