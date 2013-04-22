# ![logo](https://solsort.com/_logo.png) Dragimation

Draggable bottom of an image animation/effect - will be part of a menu...

# What

Drag bottom of image around, (special effect), should work on:

- ie8+, webkit, blink, gecko
- desktops, tablets, - not necessarily mobile

# How

How: the following approaches was considered:

- 2d-grid transformation
- canvas render transformation
- pregenerated image transform with alphas

The 2d-grid is the most approachable, so this is what we start out doing

## TODO

- extract tiles from image
- render tiles in mesh
- transform mesh by mouse position
- drag event, and only transform when dragging

# Split into subimages

    gridSize = 40

# Handle drag

    if Meteor.isClient
        Meteor.startup ->
            $(".drag").on "mousedown", ->
                console.log this
 
