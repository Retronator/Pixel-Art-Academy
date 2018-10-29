# A base class for mixins.
#
# The class throws a more meaningful error for the following class methods which are not available
# for mixins:
#
# * [`register`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_class_register)
# * [`renderComponent`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_class_renderComponent)
# * [`renderComponentToHTML`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_class_renderComponentToHTML)
#
class CommonMixin extends share.CommonComponentBase

for classMethod in ['register', 'renderComponent', 'renderComponentToHTML']
  CommonMixin[classMethod] = ->
    throw new Error "Not available for mixins."
