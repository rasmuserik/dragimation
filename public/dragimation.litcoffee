# ![logo](https://solsort.com/_logo.png) Dragimation

Draggable animation/effect - will be part of a menu...

This is just a proof of concept, errors may occur. Seems to work with Chrome, Firefox, 

# TODO

- handle touch events
- callbacks on done etc.
- maybe IE5.5+ support via non-standard matrix filter

# Source code

Define `dragimation` function on global object

    window.dragimation = ($elems, ypos)->

## Handle clicks

        $elems.on "mousedown", ->
            initialiseMovement this

Listen for movement and mouseup on body as long as touched, then reset transform.

            $("body").on "mousemove", move
            $("body").on "mouseup mouseleave", ->
                $("body").off "mousemove", move
                $dragged.css "transform", "matrix(1,0,0,1,0,0)"
                $dragged.css "-webkit-transform", "matrix(1,0,0,1,0,0)"
                $dragged.css "-ms-transform", "matrix(1,0,0,1,0,0)"
                $dragged.css "-moz-transform", "matrix(1,0,0,1,0,0)"
                false
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
            $dragged = $ dragged
            pos = $dragged.offset()
            x0 = pos.left
            y0 = pos.top
            xscale = $dragged.outerWidth() 
            yscale = $dragged.outerHeight() * ypos

## Handle cursor movement

Transform the dragged element on mouse moved.

        move = (e) ->

Figure out the current mouse position, with a base corresponding to the current element with origo/axis as the position and top/left-sides,

            x = (e.pageX - x0)/xscale
            y = (e.pageY - y0)/yscale


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
