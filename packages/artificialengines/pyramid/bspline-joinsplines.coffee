AP = Artificial.Pyramid

AP.BSpline.joinSplines = (splines) ->
  return [] unless splines?.length

  areSameControlPoints = (controlPointA, controlPointB) =>
    controlPointA.equals controlPointB

  areSameControlPointPairs = (controlPointChainA, controlPointChainAIndex, controlPointChainB, controlPointChainBIndex) =>
    areSameControlPoints(controlPointChainA[controlPointChainAIndex], controlPointChainB[controlPointChainBIndex]) and areSameControlPoints(controlPointChainA[controlPointChainAIndex + 1], controlPointChainB[controlPointChainBIndex + 1])

  tryJoinControlPointChains = (controlPointChain, candidateControlPointChain) =>
    candidateControlPointChainOrientations = [
      candidateControlPointChain
      candidateControlPointChain.slice().reverse()
    ]

    for orientedCandidateControlPointChain in candidateControlPointChainOrientations
      if areSameControlPointPairs controlPointChain, controlPointChain.length - 2, orientedCandidateControlPointChain, 0
        return [controlPointChain..., orientedCandidateControlPointChain[2...]...]

      if areSameControlPointPairs orientedCandidateControlPointChain, orientedCandidateControlPointChain.length - 2, controlPointChain, 0
        return [orientedCandidateControlPointChain..., controlPointChain[2...]...]

    null

  unjoinedControlPointChains = for spline in splines when spline.points?.length >= 3
    new THREE.Vector2().copy point for point in spline.points

  joinedSplines = []

  while unjoinedControlPointChains.length
    controlPointChain = unjoinedControlPointChains.shift()
    foundMatch = true

    # Keep merging into the current chain until no remaining segment can extend either end.
    while foundMatch
      foundMatch = false

      for candidateControlPointChain, candidateControlPointChainIndex in unjoinedControlPointChains
        joinedControlPointChain = tryJoinControlPointChains controlPointChain, candidateControlPointChain
        continue unless joinedControlPointChain

        controlPointChain = joinedControlPointChain
        unjoinedControlPointChains.splice candidateControlPointChainIndex, 1
        foundMatch = true
        break

    joinedSplines.push new AP.BSpline controlPointChain, AP.BSpline.Degrees.Quadratic

  joinedSplines
