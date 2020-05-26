###
  Based on "Simple analytic approximations to the CIE XYZ color matching functions" by
  Chris Wyman, Peter-Pike Sloan, and Peter Shirley (NVIDIA) from
  Journal of Computer Graphics Techniques 2.2 (2013): 1-11.
###

AS = Artificial.Spectrum

class AS.Color.CIE1931.ColorMatchingFunctions.Approximate
  @x: (wavelengthNanometers) ->
    t1 = (wavelengthNanometers - 442.0) * (if wavelengthNanometers < 442.0 then 0.0624 else 0.0374)
    t2 = (wavelengthNanometers - 599.8) * (if wavelengthNanometers < 599.8 then 0.0264 else 0.0323)
    t3 = (wavelengthNanometers - 501.1) * (if wavelengthNanometers < 501.1 then 0.0490 else 0.0382)
    
    0.362 * Math.exp(-0.5 * t1 * t1) + 1.056 * Math.exp(-0.5 * t2 * t2) - 0.065 * Math.exp(-0.5 * t3 * t3)

  @y: (wavelengthNanometers) ->
    t1 = (wavelengthNanometers - 568.8) * (if wavelengthNanometers < 568.8 then 0.0213 else 0.0247)
    t2 = (wavelengthNanometers - 530.9) * (if wavelengthNanometers < 530.9 then 0.0613 else 0.0322)
    
    0.821 * Math.exp(-0.5 * t1 * t1) + 0.286 * Math.exp(-0.5 * t2 * t2)
  
  @z: (wavelengthNanometers) ->
    t1 = (wavelengthNanometers - 437.0) * (if wavelengthNanometers < 437.0 then 0.0845 else 0.0278)
    t2 = (wavelengthNanometers - 459.0) * (if wavelengthNanometers < 459.0 then 0.0385 else 0.0725)

    1.217 * Math.exp(-0.5 * t1 * t1) + 0.681 * Math.exp(-0.5 * t2 * t2)
