AS = Artificial.Spectrum
AP = Artificial.Pyramid

class AS.Color.CIELAB
  @getLabForNormalizedXYZ: (xyz, target = {}) ->
    fx = @f xyz.x / 0.950489
    fy = @f xyz.y
    fz = @f xyz.z / 1.08884
    
    target.l = 116 * fy - 16
    target.a = 500 * (fx - fy)
    target.b = 200 * (fy - fz)
    
    target
  
  @f: (t) ->
    if t > @δ ** 3
      t ** (1 / 3)
    
    else
      1 / 3 * t * @δ ** -2 + 4 / 29
  
  @δ = 6 / 29
  
  @getNormalizedXYZForLab: (lab, target = new THREE.Vector3) ->
    l = (lab.l + 16) / 116
    
    target.x = 0.950489 * @fInverse l + lab.a / 500
    target.y = @fInverse l
    target.z = 1.08884 * @fInverse l - lab.b / 200

    target

  @fInverse: (t) ->
    if t > @δ
      t ** 3
    
    else
      3 * @δ ** 2 * (t - 4 / 29)

  @getLChForLab: (lab, target = {}) ->
    target.l = lab.l
    target.c = Math.sqrt lab.a ** 2 + lab.b ** 2
    target.h = Math.atan2 lab.b, lab.a
    
    target
  
  @getLabForLCh: (lch, target = {}) ->
    target.l = lch.l
    target.a = lch.c * Math.cos lch.h
    target.b = lch.c * Math.sin lch.h
    
    target
