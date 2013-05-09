# ![logo](https://solsort.com/_logo.png) Dragimation

Draggable animation/effect. Two different versions, based on different approaches to how it was wanted.

Demo available on http://dragimation.solsort.com/

Drag 2: drag effect that just skews the drag button, this code is more polished and documented, and is now in production at http://www.legolandbillundresort.com

Drag 1: drag effect distorts the image to which the buttons is attached, - this implementation is a quick proof of concept, - turned out something else (drag 2) was desired. This is kept in the bottom of the file.

# Drag 2: skew button

Define `dragimation` function on global object


    window.dragimation = ($elems, ypos, startDragFn, dragDoneFn)->

## Handle clicks

        moving = false

        $elems.on "mousedown touchstart", (event) ->
            event.preventDefault() 
            initialiseMovement this
            startDragFn?.call $dragged, event

Listen for movement and mouseup on body as long as touched, then reset transform.

            $("body").on "mousemove touchmove", move
            $("body").on "mouseup mouseleave touchend", handleTouchEnd
            false

        handleTouchEnd = (event) ->
            if not moving
                return
            moving = false
            $("body").off "mousemove touchmove", move
            $("body").off "mouseup mouseleave touchend", handleTouchEnd
            $dragged.css "transform", "matrix(1,0,0,1,0,0)"
            $dragged.css "-webkit-transform", "matrix(1,0,0,1,0,0)"
            $dragged.css "-ms-transform", "matrix(1,0,0,1,0,0)"
            $dragged.css "-moz-transform", "matrix(1,0,0,1,0,0)"
            dragDoneFn?.call $dragged, event
            false

## Keep track of element to transform

Configuration

        onlyTransformDown = false

Variable in the closure, keeps track of the currently dragged object.

        x0 = undefined
        y0 = undefined 
        $dragged = undefined
        xscale = undefined
        yscale = undefined


When starting to drag figure remember the dragged element, and its position and size.

        initialiseMovement = (dragged) ->
            moving = true
            $dragged = $ dragged
            pos = $dragged.offset()
            x0 = pos.left
            y0 = pos.top
            xscale = $dragged.outerWidth() 
            yscale = $dragged.outerHeight() * ypos

## Handle cursor movement

Transform the dragged element on mouse moved.

        move = (e) ->
            if not moving 
                return

Figure out the current mouse position, with a base corresponding to the current element with origo/axis as the position and top/left-sides,

            window.e = e

            #alert JSON.stringify [typeof e, typeof e.touches, typeof e.pageX, typeof e.touches?[0], typeof e.touches?[0]?.pageX]
            e = e.originalEvent.touches?[0] || e

            x = (e.pageX - x0)/xscale
            y = (e.pageY - y0)/yscale

            y = Math.max(y, 1) if onlyTransformDown


calculate the transformation matrix,
 
            transform = [
                1, 0,
                xscale/yscale*(x-0.5), y,
                0, 0
            ]
            transformStr = "matrix(#{transform})"

and do the transformation.

            $dragged.css 
                "transform-origin": "top"
                "-webkit-transform-origin": "top"
                "-ms-transform-origin": "top"
                "-moz-transform-origin": "top"
                "transform": transformStr
                "-webkit-transform": transformStr
                "-ms-transform": transformStr
                "-moz-transform": transformStr
## Bind it

    Meteor.startup ->
        dragimation $(".drag2"), 0.8
# Drag 1: pull image

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
        false

    Meteor.startup ->
        $(".drag").on "touchstart mousedown", handleTouch
 
