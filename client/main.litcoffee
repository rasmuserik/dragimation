# ![logo](https://solsort.com/_logo.png) Dragimation

Draggable animation/effect - will be part of a menu...

This is just a proof of concept, need refactoring, etc.

# Div transform

Just transform af div with fixed top.

    x0 = undefined
    y0 = undefined 
    ypos = .9
    xscale = undefined
    yscale = undefined
    Meteor.startup ->
        initialiseMovement()
        $("body").on "mousemove", move

    move = (e) ->
        x = (e.pageX - x0)/xscale
        y = (e.pageY - y0)/yscale
        console.log x, y
        transform = [
            1, 0,
            3*(x-0.5)/ypos, y, 
            0, 0
        ]
        console.log "c(#{transform})", xscale, yscale, xscale/yscale
        $(".dragme").css "transform-origin", "top"
        $(".dragme").css "transform", 
            "matrix(#{transform})"

    initialiseMovement = ->
        console.log $ ".dragme"
        pos = $(".dragme").position()
        console.log pos
        x0 = pos.left
        y0 = pos.top
        xscale = $(".dragme").outerWidth() 
        yscale = $(".dragme").outerHeight() * ypos

# Image drag
## What

Drag bottom of image around, (special effect), should work on:

- ie8+, webkit, blink, gecko
- desktops, tablets, - not necessarily mobile

## How

How: the following approaches was considered:

- 2d-grid transformation
- canvas render transformation
- pregenerated image transform with alphas
- y-scaled slices 

y-scaled slices is the simplest approach and may be good enough, so we try that out first.
 Started out with the 2d-grid-approach, until I got the idea for y-scaled slices.

## Transforming the image

Width of the slices in the transform. Reduce this for better looking transformation, increase this for better performance. This chould probably depend on browser version, as it run fast in chrome and sluggish in som other browsers.

    sliceWidth = 3

List of dom elements for slices

    slices = undefined

Height of undragged image

    defaultHeight = undefined

Width of the image

    w = undefined

### Split the image into canvas-slices

    makeTiles = ($img) ->
        w = $img.width()
        defaultHeight = h = $img.height()
        slices = []

        for x in [0..w] by sliceWidth

Create the canvas elements

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

### Do the transformation of the slices

    handleDrag = (x0, y0) ->
        return if not slices
        dragWidth = 150
        heights = []
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


### Binding it all together

    Meteor.startup ->
        $("#image").on "load", ->
            makeTiles $ "#image"


## Handle drag

    moved = undefined

    $moveElem = undefined

    elemX0 = undefined
    elemY0 = undefined
    mouseX0 = undefined
    mouseY0 = undefined

    handleMove = (event) ->
        dx = event.pageX - mouseX0
        dy = event.pageY - mouseY0
        x = elemX0 + dx
        y = elemY0 + dy
        $moveElem.css("left", x).css("top", y)
        x += $moveElem.width() / 2
        y = y + dy * 0.2
        handleDrag(x, y)

    handleLeave = ->
        $("body").off "mousemove touchmove", handleMove
        $("body").off "mouseleave mouseup touchend", handleLeave
        $tiles = $("#tileContainer canvas")
        $tiles.css "transition", "height 1s"
        setTimeout (-> $tiles.css "height", defaultHeight), 0
        $moveElem.css "transition", "all 1s"
        setTimeout (-> $moveElem.css "top", elemY0), 0
        setTimeout (-> $moveElem.css "left", elemX0), 1000
        $(".drag").removeClass "disabled"
        setTimeout (-> $(".drag").on "touchstart mousedown", handleTouch), 1100

     handleTouch = (event) ->
        $(".drag").off "touchstart mousedown", handleTouch
        touch = event.touches?[0] || event
        moveElem = event.currentTarget
        $moveElem = $ moveElem
        mouseX0 = touch.pageX
        mouseY0 = touch.pageY
        offset = $moveElem.offset()
        elemX0 = offset.left
        elemY0 = offset.top
        $("body").on "mousemove touchmove", handleMove
        $("body").on "mouseleave mouseup touchend", handleLeave
        $(".drag").addClass "disabled"
        $moveElem.removeClass "disabled"
        $moveElem.css "transition", "all 0s"
        $(".drag").addClass "opacity 1s"
        $("#tileContainer canvas").css "transition", "height 0s"

    Meteor.startup ->
        $(".drag").on "touchstart mousedown", handleTouch
 
