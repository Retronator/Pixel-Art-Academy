_.mixin
  # Calculates a cartesian product of multiple arrays (all possible combinations of items, one from each array).
  cartesianProduct: (arrays...) ->
    combinations = [[]]

    for array in arrays
      newCombinations = for combination in combinations
        [combination..., item] for item in array

      combinations = _.flatten newCombinations

    combinations
