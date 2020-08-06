Red [
    Author: "Yamin Ghazi AbuDaqqa"
    needs: view
]

comment{
    "
    uncompleted taks:
    1) Copy
    2) Paste
    3) Cut
    4) Use with builtin
    5) Keyboard shortcut for Undo and Redo
    "
    
    To be improved
    1) Display Recent files in open menu
}


copied-block:  []
redo-block:  []
mouse-state: 'up 
xy-new: 0x0 
set-color: green
tool: "tool-line"
tools-pen:  none
mouse-xy: none 
img: load %temp-img.png    
file-name: copy []
;Global value for slider
slider-value: 1
;block to store points for the triangle
triangle-points: []
;variable to count triangle points 
triangle-points-len: 0
temp-drawing-block: copy []
temp-drawing-items-block: copy []
temp-drawing-item-block: copy []
img-file-name: none 
img-type: none 
img1: copy []

;Shpes to draw on buttons
line-img: draw/transparent 23x23 [line 5x5 17x17] 
box-img: draw/transparent 23x23 [box 5x5 17x17] 
poly-img: draw/transparent 23x23 [polygon 5x5 10x5 15x15 12x20 2x15] 
tri-img: draw/transparent 23x23 [triangle 11x5 17x17 5x17] 
pen-img: draw/transparent 23x23 [polygon 1x10 2x10 5x10 10x5  20x5 20x15 10x15]

;Variable to store all colors which have been called from Global-context  
color-list: exclude extract load help-string tuple! 2 [glass set-color]
;color-list:  load help-string tuple! ;2 [glass set-color]


;Block to store colors as a text object
color-block: [
    style color-cell: text 25x25 [change-color face/color] 
    below
]

;Function to be called to change color 
change-color: func[pen-color ][
    
    set-color: pen-color   
]

;Function to be called when copy button pressed
copy-block: func [][
    copied-block: copy [100x100]
    
    append canvas/draw copied-block    
]



;Mouse XY position
mouse-pos: func[event][
    mouse-xy/text: rejoin["X: " event/offset/x " Y: " event/offset/y] 
]



;Function to be called when mouse cursor move 
do-move: func[event tool][
    do[mouse-pos event]
    if (mouse-state = 'down)[
        if(not tool = "tool-pen" )[
                    temp-drawing-items-block: copy temp-drawing-block
                    ]
        switch tool[
            "tool-line"[                    
                    temp-drawing-item-block:  reduce[compose [ pen (set-color) line (xy-new) (event/offset) line-width (slider-value) ] ]                                                                                            
            ]
            "tool-pen"[                    
                    repend canvas/draw reduce[compose [ pen (set-color) line (xy-new) (event/offset) line-width (slider-value) ] ]
                    xy-new: event/offset                                                                                            
            ]
            "tool-box"[                
                    temp-drawing-item-block: reduce[compose [ pen (set-color) box (xy-new) (event/offset) line-width (slider-value)] ]
            ]
            "tool-polygon"[
                temp-drawing-item-block: reduce[compose [ pen (set-color) polygon (10x10)(20x10) (30x30) (40x10) (50x50) ] ]
            ]
            "tool-triangle"[
                if (triangle-points-len = 3)[
                            temp-drawing-item-block: reduce[compose [pen (set-color) triangle (triangle-points/1) (triangle-points/2) (triangle-points/3) ] ]
                ]                 
            ]
        ]
        if (not tool = "tool-pen")[
                    repend temp-drawing-items-block temp-drawing-item-block
                    canvas/draw: temp-drawing-items-block
        ]
    ]
]

;Function to be called when mouse button released
do-up: func [] [
    mouse-state: 'up    
    
    redo-block: copy canvas/draw
    temp-drawing-block: copy canvas/draw
]

;;Function to be called when mouse button press down
do-down: func [ev tool][
     
    xy-new: ev/offset
    mouse-state: 'down 
    
    if(not empty? canvas/draw)[ 
    copied-block:    canvas/draw
    ]
        
    if (tool = "tool-triangle")[
        append triangle-points xy-new
        triangle-points-len: length? triangle-points       
    ]    
]

;Redo drawing after Undo
redo-drawing: func[][
    
    index-undo: length? canvas/draw
    index-redo: length? redo-block

    if (index-undo < index-redo )[
            index-undo: index-undo + 1                
            repend canvas/draw  [redo-block/(index-undo)]            
    ]    
]

;Undo drawing 
undo-drawing: func[][
    
    if not empty? canvas/draw [                
                remove at canvas/draw length? canvas/draw        
    ]    
]

; Function to control slider value
line-width-slider: func [data-s [percent!]][
    slider-value: to float! data-s * 10
]


;Function to display colors
area1: func[] [
        
        until[
            foreach color take/part color-list 11[
                repend color-block    ['color-cell    get color ]         
               
                repend tools-panel-1/pane   try[layout/only color-block]
            
            ]
            repend color-block  ['return]
            empty? color-list 
        ]
        ;probe tools-panel-1/pane
    
    ]

key-pressed: func[event][
    print ["key " event/key]
    switch event/key[
        #"^Z" [undo-drawing]
    ]
]


;layout block to display all panels (paint panel, tools panel & color panel)
menu-block: layout/options [
    
    size system/view/screens/1/size
    ;canvas: base 1000x600
    
    on-menu[
        switch/default event/picked[        
            file-open[open-img]
            file-save[save-img]
            file-saveas[ print canvas/size 
                save file: request-file/filter ["png" "*.png" "jpeg" "*.jpg" "gif" "*.gif"] draw (canvas/size) (canvas/draw)
            ]
            qt[quit]
            ed-undo[undo-drawing]
            ed-redo[redo-drawing]
            menu-help[alert "My paint application"] 
        ][
            open-img/recent event/picked
        ]
    ]
    
    ;style t1: text-list 100x100 data file-name [print t1/selected]
    
     across 
    panel black[    
        ;style list1: text-list 100x100 file-name
        canvas: base 1000x600 white all-over
        draw [ 
            image img 0x0 
        ]
        on-up [do-up]
        on-down [do-down event tool]   
        on-over [do-move event tool]
        ;on-key-down [key-pressed event]
                
    ]  
        
    
    
    panel yellow [
        below 
        tools-panel: panel red  280x220[
            style tools-label: button 25x25 [tool: face/extra ];bold font-size 10 black font-color red 
            below
            
            tools-label with [extra: "tool-line" image: line-img]
            tools-label with [extra: "tool-pen" image: pen-img]
            tools-label with [extra: "tool-box"  image: box-img]
            tools-label with [extra: "tool-triangle" image: tri-img]
            tools-label with [extra: "tool-polygon" image: poly-img]
              
            
            s: slider 1%
            text react [line-width-slider s/data]
            return            
        ]
        tools-panel-1: panel  cyan  200x410[]        
        do[area1]        
    ]
    
    at 10x630 
    status-panel: panel green 1020x40[
            at 10x0 
            mouse-xy: text 50x50 font-size 11
        ]
    
    
    ;img: image
][
    menu: [
        "File"[
            "Open" file-open --- 
            "Save" file-save --- 
            "Save as" file-saveas --- 
            "Recent"[] ---
            ;"Print" prnt --- 
            ;"Close" cls --- 
            "Exit" qt
        ]
        "Edit"[
            ;"Copy" ed-copy
            ;"Cut" ed-cut
           ; "Past" ed-paste
            "Undo" ed-undo 
            "Redo" ed-redo 
        ]
        "Help" menu-help 
        
    ]
]

 ;show menu-block   
 ;conv-image: to-image menu-block
 ;save/as %paint-img.png conv-image 'png 
 ;hide menu-block 


;Function to open images using file dialog or images in Recent menu 
open-img: function[/recent file][
    
    either recent[
        parse file-ref: to-string file [any [change #"|" #"/" | change "__" #" "  | skip ]] 
        img-file-name: to-file file-ref
        only-file-name: find/tail/last img-file-name "/"
    ][
        img-file-name: request-file/filter ["png" "*.png" "jpeg" "*.jpg" "gif" "*.gif"]
        only-file-name: find/tail/last img-file-name  "/"
        parse file-ref: to-string img-file-name [any [change #"/" #"|" | change #" " "__" | skip ]] 
        file-ref: to-word file-ref
    ]
    
    menu-block/text:  rejoin["File name: " only-file-name]
    
    
    if not recent [
        repend  select menu-block/menu/("File") "Recent" [
            form only-file-name  file-ref  
        ]
    ]
    
    img: load img-file-name
    
    img-type: find img-file-name "."
    canvas/draw/image: img 
]

;Function to save opened images in the same name 
save-img: func[][
    if (not img-file-name = none) [
            save file: img-file-name draw canvas/size canvas/draw 'img-type
    ]
]
 

;Show the window
view/options/flags menu-block [offset: 0x0][resize]
;repend main-view menu-block

comment{"
open-img: function [/recent file][
    img-file-name: either recent [
        to-file replace/all to-string file #"|" #"/"
    ][
        request-file/filter ["png" "*.png" "jpeg" "*.jpg" "gif" "*.gif"]
    ]
    only-file-name: last split-path img-file-name
    if not recent [
        repend lay/menu/("File")/("Recent") [
            form only-file-name 
            to-word replace/all to-string img-file-name  #"/" #"|"
        ]
    ]
    lay/text:  rejoin ["File name: " only-file-name]
    img/image: load img-file-name
    lay/size: 20 + img/size: img/image/size
]
lay: layout/options [
    on-menu [
        switch/default event/picked [
            file-open [open-img]
        ][
            open-img/recent event/picked
        ]
    ]
    img: image
][
    menu: [
        "File" [
            "Open"   file-open
            "Recent" []
        ]
    ]
]

view lay
"}
