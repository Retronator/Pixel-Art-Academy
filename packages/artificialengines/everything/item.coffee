AEt = Artificial.Everything

class AEt.Item
  # Aggregate a new part into this item.
  aggregate: (part) ->
    # Install the part into the item.
    part.install? @

    partClass = part.constructor

    while partClass
      if partEntry = _.find(@_partEntries, (partEntry) => partEntry.class is partClass)
        partEntry.part = part

      else
        @_partEntries ?= []

        @_partEntries.push
          class: partClass
          part: part

      partClass = Object.getPrototypeOf partClass

  # Remove a part from this item.
  remove: (part) ->
    # Uninstall the part from the item.
    part.uninstall? @

    _.remove @_partEntries, (partEntry) => partEntry.part is part

  # Get the item or the part that was created from the desired class.
  as: (partClass) ->
    return @ if @ instanceof partClass
    @part partClass

  # Get one of this item's parts.
  part: (partClass) ->
    partEntry = _.find @_partEntries, (partEntry) => partEntry.class is partClass
    partEntry?.part

  parts: ->
    return [] unless @_partEntries
    partEntry.part for partEntry of @_partEntries

  # See if this item can be cast into a certain type.
  is: (partClass) -> @as(partClass)?

  # See if this item has one of the parts.
  has: (partClass) -> @part(partClass)?

  # Create a new part of required class if it doesn't exist and return the part that meets the requirements.
  require: (partClass) ->
    return part if part = @as partClass

    part = new partClass
    @aggregate part

    part
