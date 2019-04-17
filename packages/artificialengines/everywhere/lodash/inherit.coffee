_.mixin
  # Allows (fake) multiple inheritance by copying properties from the parent to the child class.
  # Note that instanceof operator will return false when querying for inheritance of the parent class.
  inherit: (childClass, parentClass) ->
    isInheritableDescriptor = (descriptor) ->
      descriptor.writable and _.isFunction descriptor.value

    for property, descriptor of Object.getOwnPropertyDescriptors parentClass when isInheritableDescriptor descriptor
      childClass[property] = descriptor.value

    for property, descriptor of Object.getOwnPropertyDescriptors parentClass.prototype when property isnt 'constructor' and isInheritableDescriptor descriptor
      childClass.prototype[property] = descriptor.value
