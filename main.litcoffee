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
- y-scaled slices 

y-scaled slices is the simplest approach and may be good enough, so we try that out first.
 Started out with the 2d-grid-approach, until I got the idea for y-scaled slices.

## TODO

- extract tiles from image
- render tiles in mesh
- transform mesh by mouse position
- drag event, and only transform when dragging

# Split into subimages

    heightCuts = 1
    widthCuts = 100 

    sliceWidth = 10
    slices = undefined
    defaultHeight = undefined
    w = undefined

    makeTiles = ($img) ->
        w = $img.width()
        defaultHeight = h = $img.height()
        slices = []

        for x in [0..w] by sliceWidth
            $canvas = $ "<canvas></canvas>"
            $canvas.addClass "tile"
            $canvas.css("top", 0).css("left", x)
            $canvas.css("width", sliceWidth)
            $("#tileContainer").append $canvas
            slices.push $canvas[0] 
            canvas = $canvas[0]
            canvas.width = sliceWidth
            canvas.height = h
            ctx = $canvas[0].getContext "2d"
            ctx.width = sliceWidth
            ctx.height = h
            ctx.drawImage $img[0], x, 0, sliceWidth, h, 0, 0, sliceWidth, h

    handleDrag = (x0, y0) ->
        return if not slices
        dragWidth = 150
        heights = []
        y0 += 30
        for i in [0..slices.length - 1] by 1
            x = i * sliceWidth
            if Math.abs(x - x0) < dragWidth
                ratio = (dragWidth - Math.abs(x-x0))/dragWidth
                ratio = Math.PI * (ratio - 0.5)
                ratio = Math.sin ratio
                ratio = (ratio + 1) / 2
                slices[i].style.height = ratio * y0 + defaultHeight * (1 - ratio) + "px"
            else
                slices[i].style.height = defaultHeight + "px"



    if Meteor.isClient
        Meteor.startup ->
            $("#image").on "load", ->
                makeTiles $ "#image"
            $("body").on "mousemove", (e)->
                handleDrag(e.pageX,e.pageY)

# Handle drag

    if Meteor.isClient
        Meteor.startup ->
            $(".drag").on "mousedown", ->
                console.log this
 
