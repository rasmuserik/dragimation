# ![logo](https://solsort.com/_logo.png) Dragimation

Draggable animation/effect - will be part of a menu...

This is just a proof of concept, errors may occur. Seems to work with Chrome, Firefox, 

# TODO

- handle touch events
- only drag downwards
- callbacks on done etc.
- ie9

# Source code

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

        handleTouchEnd = ->
            dragDoneFn?.call $dragged, event if moving
            moving = false
            $("body").off "mousemove touchmove", move
            $("body").off "mouseup mouseleave touchend", handleTouchEnd
            $dragged.css "transform", "matrix(1,0,0,1,0,0)"
            $dragged.css "-webkit-transform", "matrix(1,0,0,1,0,0)"
            $dragged.css "-ms-transform", "matrix(1,0,0,1,0,0)"
            $dragged.css "-moz-transform", "matrix(1,0,0,1,0,0)"
            false

## Keep track of element to transform

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

            y = Math.max(y, 1)


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
