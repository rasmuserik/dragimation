# Dragimation

Draggable bottom of an image - will be part of a menu...

# Handle drag

    if Meteor.isClient
        Meteor.startup ->
            $(".drag").on "mousedown", ->
                console.log this
 
# Split into subimages

    gridSize = 40

