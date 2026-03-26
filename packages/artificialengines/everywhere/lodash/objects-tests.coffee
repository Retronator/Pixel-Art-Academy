Tinytest.add 'artificialengines - lodash - objectDifference', (test) ->
  # Basic types
  test.equal _.objectDifference(1, 1), {}
  test.equal _.objectDifference(1, 2), 2
  test.equal _.objectDifference('a', 'a'), {}
  test.equal _.objectDifference('a', 'b'), 'b'
  test.equal _.objectDifference(true, true), {}
  test.equal _.objectDifference(true, false), false
  test.equal _.objectDifference(null, null), {}
  test.equal _.objectDifference(null, undefined), undefined
  
  # Dates
  test.equal _.objectDifference(new Date(123), new Date(123)), {}
  test.equal _.objectDifference(new Date(123), new Date(456)), new Date(456)
  
  # NaN
  test.equal _.objectDifference(NaN, NaN), {}
  
  # Objects: simple
  test.equal _.objectDifference({a: 1}, {a: 1}), {}
  test.equal _.objectDifference({a: 1}, {a: 2}), {a: 2}
  test.equal _.objectDifference({a: 1}, {b: 1}), {a: "__deleted__", b: 1}
  test.equal _.objectDifference({a: 1}, {a: 1, b: 2}), {b: 2}
  test.equal _.objectDifference({a: 1, b: 2}, {a: 1}), {b: "__deleted__"}
  
  # Objects: nested
  test.equal _.objectDifference({a: {b: 1}}, {a: {b: 1}}), {}
  test.equal _.objectDifference({a: {b: 1}}, {a: {b: 2}}), {a: {b: 2}}
  test.equal _.objectDifference({a: {b: 1}}, {a: {c: 1}}), {a: {b: "__deleted__", c: 1}}
  
  # Arrays: simple
  test.equal _.objectDifference([1, 2], [1, 2]), {}
  test.equal _.objectDifference([1, 2], [1, 3]), ["__unchanged__", 3]
  test.equal _.objectDifference([1, 2], [1]), ["__unchanged__"]
  test.equal _.objectDifference([1], [1, 2]), ["__unchanged__", 2]
  
  # Arrays: nested objects
  test.equal _.objectDifference([{a: 1}], [{a: 1}]), {}
  test.equal _.objectDifference([{a: 1}], [{a: 2}]), [{a: 2}]
  test.equal _.objectDifference([{a: 1}, {b: 2}], [{a: 1}, {b: 3}]), ["__unchanged__", {b: 3}]
  
  # Complex nesting
  a =
    name: "John"
    address:
      city: "New York"
      zip: 10001
    tags: ["friend", "work"]
    meta:
      active: true
      
  b =
    name: "John"
    address:
      city: "Boston"
      zip: 10001
    tags: ["friend", "home", "work"]
    meta:
      active: false
      
  expected =
    address:
      city: "Boston"
    tags: ["__unchanged__", "home", "work"]
    meta:
      active: false
      
  test.equal _.objectDifference(a, b), expected

  # Test consistency with applyObjectDifference.
  aClone = EJSON.clone a
  difference = _.objectDifference aClone, b
  _.applyObjectDifference aClone, difference
  test.equal aClone, b
