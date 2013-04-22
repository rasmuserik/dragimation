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

    heightCuts = 1
    widthCuts = 100 

    makeTile = ($img, x, y, w, h) ->
        $canvas = $ "<canvas></canvas>"
        $canvas.addClass "tile"
        $canvas.css("top", y).css("left", x)
        $("#tileContainer").append $canvas
        canvas = $canvas[0]
        canvas.width = w
        canvas.height = h
        $canvas.css "height", h + Math.random() * 100
        ctx = canvas.getContext "2d"
        ctx.width = w
        ctx.height = h
        ctx.drawImage $img[0], x, y, w, h, 0, 0, w, h
        return {
            dom: canvas
            x: x
            y: y
            }


    makeTiles = ($img) ->
        w = $img.width()
        h = $img.height()
        gridWidth = Math.floor w / widthCuts
        gridHeight = Math.floor h / heightCuts
        for x in [0..w] by gridWidth
            for y in [0..h] by gridHeight
                console.log makeTile $img, x, y, gridWidth, gridHeight



    if Meteor.isClient
        Meteor.startup ->
            $("#image").on "load", ->
                makeTiles $ "#image"
            $("body").on "mousemove", (e)->
                console.log e.pageX, e.pageY

# Handle drag

    if Meteor.isClient
        Meteor.startup ->
            $(".drag").on "mousedown", ->
                console.log this
 
