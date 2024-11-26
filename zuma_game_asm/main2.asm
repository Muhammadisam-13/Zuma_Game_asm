INCLUDE irvine32.inc
INCLUDE macros.inc
INCLUDELIB winmm.lib

PlaySound PROTO, pszSound:PTR BYTE, hmod:DWORD, fdwSound:DWORD

.data
    menuMusic BYTE "F:\zuma_game_asm\zuma_game_asm\menu.wav", 0   ; Define the file name for the menu sound
    gameMusic BYTE "F:\zuma_game_asm\zuma_game_asm\music.wav", 0   ; Define the file name for the menu sound
    SND_FILENAME DWORD 00020000h
    SND_LOOP equ 00000008h
    SND_ASYNC equ 00000001h
    SND_PURGE equ 00000002h  ; Stops any currently playing sound

	Ball struct						; Ball structure
		sprite db ?
		xPos db ?
		yPos db ?
		exists db ?
        ballColor dd ?
	Ball ends

	Player struct					; Player structure
		sprite db ?
		xPos db ?
		yPos db ?
		Bullet Ball <>
	Player ends
    playerName db 20 dup(?)
				
; Rotation keys
	move_up db 'W'									
	move_up_right db 'E'
	move_right db 'D'
	move_down_right db 'X'
	move_down db 'S'
	move_down_left db 'Z'
	move_left db 'A'
	move_up_left db 'Q'					

	XLIMIT db 100					; Console ranges
	YLIMIT db 24
	
	; Game Objects
	player1 Player <>
    BallChain Ball 100 dup(<'O',?,?,1,?>)
    ballCount = 80

	; Extra variables		
    gameEnd db 0
    xPos db 56      ; Column (X)
    yPos db 15      ; Row (Y)
    xDir db 0
    yDir db 0
    ; Default character (initial direction)
    inputChar db 0
    direction db "d"
    ballChainDirection db 1
	score db 0
	temp db ?
	temp1 dd ?
	space db ' '					
	border BYTE "========================================================================================================================",0
	border1 BYTE "|",0ah,0
	border2 BYTE "|",0  

    upperBoundary db 3
    leftBoundary db 30
    lowerBoundary db 24
    rightBoundary db 90
	
	 ; Characters representing rotations
    up_char db '^'
    down_char db 'v'
    left_char db '<'
    right_char db '>'

    ; Default character (initial direction)
    current_char db '^'

	; Colors for the emitter and player
    color_red db 4       ; Red
    color_green db 2     ; Green
    color_yellow db 14   ; Yellow (for fire symbol)
    current_color db 4   ; Default player color (red)
    emitter_color1 db 2  ; Green
    emitter_color2 db 4  ; Red
    fire_color db 14     ; Fire symbol color (Yellow)

    ; Emitter properties
    emitter_symbol db 'O'
    emitter_row db 3    ; Two rows above player (fixed row for emitter)
    emitter_col db 25    ; Starting column of the emitter

    ; Fire symbol properties (fired from player)
    fire_symbol db 'O'
    fire_row db 0        ; Fire will be fired from the player's position
    fire_col db 0        ; Initial fire column will be set in the update logic
	
	Zuma_art db '                       .+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.',13,10
			db '                        (    ______   _ __  __    _       ____    _    __  __ _____      )',13,10
			db '                        )   |__  / | | |  \/  |  / \     / ___|  / \  |  \/  | ____|    (',13,10
			db '                        (     / /| | | | |\/| | / _ \   | |  _  / _ \ | |\/| |  _|       )',13,10
			db '                        )    / /_| |_| | |  | |/ ___ \  | |_| |/ ___ \| |  | | |___     (',13,10
			db '                        (   /____|\___/|_|  |_/_/   \_\  \____/_/   \_\_|  |_|_____|     )',13,10
			db '                        )                                                               (',13,10 
			db '                        (                                                                 )',13,10
			db '                        "+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"+.+"',13,10 
			db 0

 Zuma_art1 db '                         ________  ___  ___  _____ ______   ________      ',13,10
          db '                          |\_____  \|\  \|\  \|\   _ \  _   \|\   __  \     ',13,10
          db '                          \|___/  /\ \  \\\  \ \  \\\__\ \  \ \  \|\  \    ',13,10
          db '                              /  / /\ \  \\\  \ \  \\|__| \  \ \   __  \   ',13,10
          db '                             /  /_/__\ \  \\\  \ \  \    \ \  \ \  \ \  \  ',13,10
          db '                             |\________\ \_______\ \__\    \ \__\ \__\ \__\',13,10
          db '                               \|_______|\|_______|\|__|     \|__|\|__|\|__|',13,10
          db 0


	START         DB '                                               ___ ___ ___ ___ ___   ',13,10
                  DB '                                              / __|_ _| . | . |_ _|  ',13,10
                  DB '                                              \__ \| ||   |   /| |   ',13,10
                  DB '                                              <___/|_||_|_|_\_\|_|   ',13,10
                  DB 0   

INSTRUCTIONS    DB '                                    ._ _ _ ___ ___ ___ _ _ ___ ___ _ ___ _ _ ___.',13,10
                DB '                                    | | \ / __|_ _| . | | |  _|_ _| | . | \ / __>',13,10
                DB '                                    | |   \__ \| ||   |   | <__| || | | |   \__ \',13,10
                DB '                                    |_|_\_<___/|_||_\_`___`___/|_||_`___|_\_<___/',13,10
                DB 0
            
	EXITED       DB '                                                 ._____  _ _ ___.  ',13,10
                 DB '                                                 | __\ \/ | |_ _|  ',13,10
                 DB '                                                 | _> \ \ | || |   ',13,10
                 DB '                                                 |____/\_\|_||_|   ',13,10
                 DB 0

    INSTRUCTIONS_SCREEN             db'CONTROLS:                                                                                        ',13,10
                               db'                                                                                                 ',13,10
                               db' 1. Use Q W E A S D Z X to rotate the frog                                       ',13,10
                               db' 2. Press SPACE to shoot a ball and try to match THREE or more balls together to destroy the chain                        ',13,10
                               db'                                                                                                 ',13,10
                               db' GAMEPLAY:                                                                                       ',13,10
                               db'                                                                                                 ',13,10
                               db' 1. Frog rotates in the middle and can shoot in eight directions                              ',13,10
                               db' 2. Avoid letting the ball chain close in to the frog                              ',13,10                    
                               db'                                                                                                 ',13,10
                               db' SCORING:                                                                                        ',13,10
                               db'                                                                                                 ',13,10
                               db' 1. Making combinations of THREE or more earns points                                                         ',13,10
                               db' 2. Making combinations of more than THREE earns you bonus points.                          ',13,10
                               db' 3. Bonus points are awarded for completing a level.                                              ',13,10
                               db'                                                                                                 ',13,10
                               db' GAME OVER:                                                                                      ',13,10
                               db'                                                                                                 ',13,10
                               db' 1. If the ball chain closes in before the matches are made, you LOSE!           ',13,10
                               db' 2. Losing all lives ends the game. You have THREE lives to start.                                ',13,10
                               db 0


; --------------------------------------------------------------------------------------------------------------				
.code
playMenuMusic PROC
    push eax            
    push edx
    invoke PlaySound, eax, 0, SND_LOOP or SND_ASYNC
    pop edx
    pop eax
    ret                 
playMenuMusic ENDP

playGameMusic PROC
    push eax            
    push edx
    invoke PlaySound, eax, 0, SND_LOOP or SND_ASYNC
    pop edx
    pop eax
    ret                 
playGameMusic ENDP

stopMenuMusic PROC
    ; Stops any currently playing sound
    push 0                                    ; pszSound: Null
    push 0                                    ; hmod: No specific module
    push SND_PURGE                            ; fdwSound: Purge
    call PlaySound                            ; Call PlaySound
    ret
stopMenuMusic ENDP

DrawPlayer PROC
	mov player1.ypos,13
	mov player1.xpos,55
    mov bl,current_char
    mov player1.sprite,bl
	mov dh,player1.ypos
	mov dl,player1.xpos
	call gotoxy

	mov eax,cyan
	call setTextColor
	mov al,player1.sprite
	call writeChar

	ret
DrawPlayer ENDP

instructionsMenu PROC
    call ClrScr
    mov edx,OFFSET INSTRUCTIONS_SCREEN
    call writeString
    call crlf

    CheckEscapeCondition:
        mov eax,50
        call Delay
        call ReadKey
        cmp dl,VK_ESCAPE
        je ExitInstructionsMenu
        jmp CheckEscapeCondition
    ExitInstructionsMenu:
    call ClrScr
    call displayButtons
    ret
instructionsMenu ENDP

inputPlayerName PROC
    mwrite "ENTER YOUR NAME: "
    mov edx,OFFSET playerName
    mov ecx,20
    call readString

    ret
inputPlayerName ENDP
DetectKeyInput PROC

    mwrite "Press 'S' to start"
    call crlf
    mwrite "Press 'I' for instructions"
    call crlf
    mwrite "Press 'E' to Exit"
    call crlf

ContinueDetecting:
    mov eax,50
    call Delay
    call ReadKey
    cmp dl,'S'
    je SCondition
    cmp dl,'I'
    je ICondition
    cmp dl,'E'
    je ECondition
    jmp ContinueDetecting

    SCondition:
    mov bl,2
    ret

    ICondition:
    call instructionsMenu
    jmp DetectKeyInput
    ECondition:
    exit

    ElseCondition:
    ret
DetectKeyInput ENDP

displayButtons PROC
; Displaying game title
	mov dl,0
	mov dh,1
	call gotoxy
	mov edx,OFFSET zuma_art  
	mov eax,yellow
	call setTextColor
	call writeString
	call crlf
    
; Start button
    mov dl,0 
	mov dh,10
	call gotoxy
    mov edx,OFFSET start   
	mov eax,yellow
	call setTextColor
	call writeString
	call crlf

; Instructions button
    mov dl,0
	mov dh,15
	call gotoxy
    mov edx,OFFSET instructions   
	mov eax,yellow
	call setTextColor
	call writeString
	call crlf

; Exit button
    mov dl,0
	mov dh,20
	call gotoxy
    mov edx,OFFSET exited   
	mov eax,yellow
	call setTextColor
	call writeString
	call crlf

    ret
displayButtons ENDP

initializeScreen PROC
    call displayButtons

CheckKeyInputs:
    call DetectKeyInput
    cmp bl,2
    jne CheckKeyInputs
	call Clrscr ; clear the screen
    

    call inputPlayerName
    call ClrScr

; Displaying score and title
	mov dl,0
	mov dh,5

	mov eax,lightblue (black * 16)
    call SetTextColor
	mwrite "SCORE: "
	
	mov temp1,eax
	mov eax,0
	mov al,score
	call writeInt
	mov eax,temp1

	mov eax,yellow (black * 16)
    call SetTextColor
    mov dl,0
    mov dh,29
    call Gotoxy
    mov edx,OFFSET border
    call WriteString
    mov dl,0
    mov dh,1
    call Gotoxy
    mov edx,OFFSET border
    call WriteString

    mov ecx,27
    mov dh,2
    initializeBorder1:
		mov dl,0
		call Gotoxy
		mov edx,OFFSET border1
		call WriteString
		LOOP initializeBorder1

    mov ecx,27
    mov dh,2
    mov temp,dh

    initializeBorder2:
		mov dh,temp
		mov dl,119
		call Gotoxy
		mov edx,OFFSET border2
		call WriteString
		inc temp
		LOOP initializeBorder2
	ret
initializeScreen ENDP

DrawBallChain PROC USES eax ecx edx
    LOCAL currentColor:dword
	mov dl, emitter_col
    mov dh, emitter_row
    mov ecx,0
    mov esi,0
    mov eax, blue
    call SetTextColor
    emitterLoop: 
        mov currentColor,eax
        mov al,ballChain[esi].sprite
        call Gotoxy
        call WriteChar

        mov eax,currentColor
        cmp eax,blue
        jne set_blue
        mov eax,red
        mov currentColor,eax
        call SetTextColor
        jmp next_symbol

    set_blue:
        mov eax,blue
        mov currentColor,eax
        call setTextColor

    next_symbol:
        mov ballChain[esi].xPos,dl
        mov ballChain[esi].yPos,dh
        inc dl               
        add esi,SIZEOF Ball         
        inc ecx
        mov ballChain[esi].ballColor,eax 
        cmp ecx,ballCount
        jne emitterLoop
        mov dl, emitter_col

        ret
	ret
DrawBallChain ENDP

reDrawBallChain PROC USES eax edx ecx
    mov esi,0
    mov ecx,ballCount
    ReDrawLoop:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        mov eax,ballChain[esi].ballColor
        call setTextColor
        call Gotoxy
        mov al,ballChain[esi].sprite
        call WriteChar
        add esi,SIZEOF Ball
        LOOP ReDrawLoop
    ret
reDrawBallChain ENDP

UpdateLoopBallChain PROC USES ecx
    LOCAL tmpX:BYTE
    LOCAL tmpY:BYTE
    LOCAL old_dl:BYTE
    LOCAL old_dh:BYTE
    
; Initial conditions
    mov esi,0
    mov ecx,ballCount

; Storing original value of the first ball in temp
    mov al,ballChain[esi].xPos
    mov tmpX,al
    mov al,ballChain[esi].yPos
    mov tmpY,al

; Erase the ball at the current position
    mov old_dl,dl ; Store in temp
    mov old_dh,dh
    mov dl,ballChain[esi].xPos
    mov dh,ballChain[esi].yPos
    mov al,' '
    call gotoxy
    call writeChar

; Restore value of dh and dl
    mov dl,old_dl
    mov dh,old_dh

; Update the first ball's position
    mov ballChain[esi].xPos,dl
    mov ballChain[esi].yPos,dh

; Move to the next ball before the loop starts
    add esi,SIZEOF Ball
    dec ecx

    UpdateL1:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos

        mov al,' '
        call gotoxy
        call writeChar
            
        mov al,tmpX
        mov bl,ballChain[esi].xPos
        mov tmpX,bl
        mov ballChain[esi].xPos,al
        mov al,tmpY
        mov bl,ballChain[esi].yPos
        mov tmpY,bl
        mov ballChain[esi].yPos,al

        add esi,SIZEOF Ball
        Loop UpdateL1
    ret
UpdateLoopBallChain ENDP

UpdateBallChain PROC  
    LOCAL tmpX:BYTE
    LOCAL tmpY:BYTE
	push eax
    push ecx
    push edx

; Initial conditions
    mov esi,0
    mov ecx,ballCount

; Store x and y positions of the first ball
    mov al,ballChain[esi].xPos
    mov tmpX,al
    mov al,ballChain[esi].yPos
    mov tmpY,al

    mov al,ballChainDirection
    mov esi,0
    mov ecx,ballCount

    cmp al,1
    je MOVINGLEFT
    cmp al,2
    je MOVINGDOWN
    cmp al,3
    je MOVINGRIGHT
    cmp al,4
    je MOVINGUP
    mov dl,ballChain[esi].xPos
    mov dh,ballChain[esi].xPos
    cmp dl,10
    jle MOVINGDOWN
 
    MOVINGLEFT:    
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        dec dl ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call reDrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        cmp dl,leftBoundary
        jg ENDUPDATE
        mov al,2 ; change direction to down
        mov ballChainDirection,al
        jmp ENDUPDATE
        

    
    MOVINGDOWN:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        inc dh ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call reDrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dh,ballChain[esi].yPos
        cmp dh,lowerBoundary
        jl ENDUPDATE
        mov al,3 ; change direction to right
        mov ballChainDirection,al
        jmp ENDUPDATE

    MOVINGRIGHT:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        inc dl ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call reDrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        cmp dl,rightBoundary
        jl ENDUPDATE
        mov al,4 ; change direction to up
        mov ballChainDirection,al
        jmp ENDUPDATE

    MOVINGUP:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        dec dh ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call reDrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        cmp dh,upperBoundary
        jle LoopSpiral
        jmp ENDUPDATE

    LoopSpiral:
    mov al,1
    mov ballChainDirection,al
    inc leftBoundary
    dec rightBoundary
    inc upperBoundary
    dec lowerBoundary

    ENDUPDATE:

	ret
UpdateBallChain ENDP

CheckIfBulletFired PROC
    CheckKey1:
    mov eax,50
    call Delay
    call ReadKey

    cmp dl,'W'
    je wcondition
    jmp CheckKey2

    cmp dl,'Q'
    je qcondition
    jmp CheckKey2

    cmp dl,'E'
    je econdition
    jmp CheckKey2

    cmp dl,'A'
    je acondition
    jmp CheckKey2

    cmp dl,'D'
    je dcondition
    jmp CheckKey2

    cmp dl,'X'
    je wcondition
    jmp CheckKey2

    cmp dl,'Z'
    je zcondition
    jmp CheckKey2

    wcondition:
    mov al,'w'
    mov direction,al
    jmp CheckKey2

    qcondition:
    mov al,'q'
    mov direction,al
    jmp CheckKey2

    econdition:
    mov al,'e'
    mov direction,al
    jmp CheckKey2

    acondition:
    mov al,'a'
    mov direction,al
    jmp CheckKey2

    dcondition:
    mov al,'d'
    mov direction,al
    jmp CheckKey2

    xcondition:
    mov al,'x'
    mov direction,al
    jmp CheckKey2

    zcondition:
    mov al,'z'
    mov direction,al
    jmp CheckKey2

	CheckKey2:
    mov eax,50
    call Delay 

    call ReadKey  

    cmp dl,' '
    jne NotFired
	call fire
	NotFired:
	
	ret
CheckIfBulletFired ENDP

fire PROC
    ; Fire a projectile from the player's current face direction

    mov dl, player1.xPos      ; Fire column starts at the player's X position
    mov dh, player1.yPos      ; Fire row starts at the player's Y position

    mov fire_col, dl  ; Save the fire column position
    mov fire_row, dh  ; Save the fire row position

    mov al, direction
    cmp al, "w"
    je fire_up

    cmp al, "x"
    je fire_down

    cmp al, "a"
    je fire_left

    cmp al, "d"
    je fire_right

    cmp al, "q"
    je fire_upleft

    cmp al, "e"
    je fire_upright

    cmp al, "z"
    je fire_downleft

    cmp al, "c"
    je fire_downright

    jmp end_fire

fire_up:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, -1
    jmp fire_loop

fire_down:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, 1
    jmp fire_loop

fire_left:
    mov fire_col, 55         ; Move fire position leftwards
    mov fire_row, 16         ; Center fire position
    mov xDir, -1
    mov yDir, 0
    jmp fire_loop

fire_right:
    mov fire_col, 59         ; Move fire position rightwards
    mov fire_row, 16         ; Center fire position
    mov xDir, 1
    mov yDir, 0
    jmp fire_loop

fire_upleft:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 55         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, -1
    jmp fire_loop

fire_upright:
    mov fire_row, 14         ; Move fire position upwards
    mov fire_col, 59         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, -1
    jmp fire_loop

fire_downleft:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 55         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, 1
    jmp fire_loop

fire_downright:
    mov fire_row, 18         ; Move fire position downwards
    mov fire_col, 59         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, 1
    jmp fire_loop

fire_loop:
    ; Initialise fire position
    mov dl, fire_col
    mov dh, fire_row
    call GoToXY

    ; Loop to move the fireball in the current direction
    L1:

        ; Ensure fire stays within the bounds of the emitter wall
        cmp dl, 20            ; Left wall boundary
        jle end_fire

        cmp dl, 96            ; Right wall boundary
        jge end_fire

        cmp dh, 5             ; Upper wall boundary
        jle end_fire

        cmp dh, 27            ; Lower wall boundary
        jge end_fire

        ; Print the fire symbol at the current position
        movzx eax, fire_color    ; Set fire color
        call SetTextColor

        add dl, xDir
        add dh, yDir
        call Gotoxy

        mWrite "O"

        ; Continue moving fire in the current direction (recursive)
        mov eax, 30
        call Delay

        ; erase the fire before redrawing it
        call GoToXY
        mWrite " "

        jmp L1

    end_fire:
        mov dx, 0
        call GoToXY

    ret
fire ENDP

checkForKeyPress PROC
    ; Check if a key has been pressed and update player position or shape
    call ReadKey         ; Wait for a key press

    cmp ah, 48h          ; Up arrow key
    je up_arrow
    cmp ah, 50h          ; Down arrow key
    je down_arrow
    cmp ah, 4Dh          ; Right arrow key
    je right_arrow
    cmp ah, 4Bh          ; Left arrow key
    je left_arrow

    ret                  ; If no key matches, return to main loop

up_arrow:
    cmp player1.yPos, 10     ; Prevent moving above the emitter wall
    jle no_move
    mov al,up_char      ; Set the character to '^'
    mov player1.sprite,al
    dec byte ptr player1.yPos ; Move up
    ; Print the updated player character
    mov al,player1.sprite
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

down_arrow:
    cmp player1.yPos, 12     ; Prevent moving below the emitter wall
    jge no_move
    mov al, down_char    ; Set the character to 'v'
    mov  player1.sprite, al
    inc byte ptr player1.yPos; Move down
    ; Print the updated player character
    mov al,player1.sprite
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

right_arrow:
    cmp player1.xPos, 79     ; Prevent moving beyond the right wall
    jge no_move
    mov al,right_char   ; Set the character to '>'
    mov player1.sprite,al
    inc byte ptr player1.xPos; Move right
    ; Print the updated player character
    mov al,player1.sprite
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

left_arrow:
    cmp player1.xPos, 1      ; Prevent moving beyond the left wall
    jle no_move
    mov al, left_char    ; Set the character to '<'
    mov player1.sprite, al
    dec byte ptr player1.xPos ; Move left
    ; Print the updated player character
    mov al,player1.sprite
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

no_move:
    ret
checkForKeyPress ENDP

RUN_ZUMA PROC
    lea eax, menuMusic
    call playMenuMusic
    call initializeScreen
    call DrawPlayer
    call DrawBallChain
    lea eax,gameMusic
    call playGameMusic
    gameLoop:      
        call checkIfBulletFired
        call updateBallChain
	jmp GameLoop	
    ExitGame:
    ret
RUN_ZUMA ENDP

main PROC
	call RUN_ZUMA
	exit
main ENDP
end main
