AM = Artificial.Mirage

class Artificial.Mirage.AutoResizeInputMixin extends BlazeComponent
  onRendered: ->
    $clone = $('<div style="position:absolute;top:0;left:0;bottom:0;visibility:hidden;white-space:pre-wrap;"></div>')
    $input = @mixinParent().$('input')
    $input.after($clone)

    updateClone = =>
      # Clone the text in the text area.
      $clone.text("#{$input.val()} ")

      # Measure the width it uses.
      newWidth = $clone.width()

      # Now set this to the textarea itself to match, except if it would resize it to 0.
      $input.width(newWidth + @mixinParent().autoResizeInputPadding) if newWidth

    updateClone()
    
    $input.on('input', updateClone)
