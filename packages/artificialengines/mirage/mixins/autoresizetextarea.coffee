AM = Artificial.Mirage

class Artificial.Mirage.AutoResizeTextareaMixin extends BlazeComponent
  onRendered: ->
    $clone = $('<div style="position:absolute;top:0;left:0;right:0;visibility:hidden;white-space:pre-wrap;"></div>')
    $textarea = @mixinParent().$('textarea')
    $textarea.after($clone)

    updateClone = =>
      # Clone the text in the text area.
      $clone.text("#{$textarea.val()} ")

      # Measure the height it uses.
      newHeight = $clone.height()

      # Now set this to the textarea itself to match, except if it would resize it to 0.
      $textarea.height(newHeight) if newHeight

    updateClone()

    $textarea.on('input', updateClone)
