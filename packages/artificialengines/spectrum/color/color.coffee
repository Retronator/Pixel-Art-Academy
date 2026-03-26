AS = Artificial.Spectrum

_start = new THREE.Vector3
_end = new THREE.Vector3
_value = new THREE.Vector3
_startToEnd = new THREE.Vector3
_startToValue = new THREE.Vector3

class AS.Color
  @inverseLerp: (startColor, endColor, valueColor) ->
    _start.set startColor.r, startColor.g, startColor.b
    _end.set endColor.r,   endColor.g,   endColor.b
    _value.set valueColor.r, valueColor.g, valueColor.b
    
    _startToEnd.subVectors _end, _start
    lengthSquared = _startToEnd.lengthSq()
    
    # Nothing to do if start and end are the same.
    return 0 unless lengthSquared
    
    # Project value to line between start and end.
    _startToValue.subVectors _value, _start
    _startToValue.dot(_startToEnd) / lengthSquared
