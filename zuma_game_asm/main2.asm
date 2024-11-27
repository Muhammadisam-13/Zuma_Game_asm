comment %
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
    bullet Ball <'O',?,?,0,?>

	; Extra variables		
    ballCount = 80
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
	border BYTE "=====================================================================================",0
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


    PAUSE_SCREEN db "                                       ____   _   _   _ ____  _____ ____  ", 0Dh, 0Ah
             db "                                       |  _ \ / \ | | | / ___|| ____|  _ \ ", 0Dh, 0Ah
             db "                                       | |_) / _ \| | | \___ \|  _| | | | |", 0Dh, 0Ah
             db "                                       |  __/ ___ \ |_| |___) | |___| |_| |", 0Dh, 0Ah
             db "                                       |_| /_/   \_\___/|____/|_____|____/ ", 0Dh, 0Ah, 0



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

stopMusic PROC
    ; Stops any currently playing sound
    push 0                                    ; pszSound: Null
    push 0                                    ; hmod: No specific module
    push SND_PURGE                            ; fdwSound: Purge
    call PlaySound                            ; Call PlaySound
    ret
stopMusic ENDP

DrawPlayer PROC
	mov player1.ypos,13
	mov player1.xpos,55
    mov bl,current_char
    mov player1.sprite,'@'
	mov dh,player1.ypos
	mov dl,player1.xpos
	call gotoxy

	mov eax,cyan
	call setTextColor
	mov al,player1.sprite
	call writeChar

	ret
DrawPlayer ENDP

instructionsMenu PROC USES eax edx
    call ClrScr
    mov eax,yellow
    call setTextColor
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

EnablePauseScreen PROC
    call ClrScr
    mov eax,green
    call setTextColor
    mov dh,10
    mov dl,0
    call gotoxy
    mov edx,OFFSET PAUSE_SCREEN
    call writeString
    call crlf

    DetectKeyPress:
    mov eax,50
    call Delay
    call ReadKey
    cmp dl,VK_ESCAPE
    je ExitingPauseScreen
    jmp DetectKeyPress

    ExitingPauseScreen:
    call ClrScr
    call initializeGameScreen
    call drawPlayer
    ret
EnablePauseScreen ENDP

HandleInput PROC
    DetectKeyPress:     ; Check if pause key pressed
    mov eax,50
    call Delay
    call ReadKey
    cmp dl,'P'
    je PauseInputDetected

    call CheckIfBulletFired     ; Check if bullet fired
    jmp ExitFunc

PauseInputDetected:
    call EnablePauseScreen
    jmp ExitFunc
    
ExitFunc:
    ret
HandleInput ENDP

CheckIfBulletFired PROC 
    ; check direction changes
    cmp dl, 'W'   ; Up
    je SetDirectionUp
    cmp dl, 'X'   ; Down
    je SetDirectionDown
    cmp dl, 'A'   ; Left
    je SetDirectionLeft
    cmp dl, 'D'   ; Right
    je SetDirectionRight
    cmp dl, 'Q'   ; Up-left
    je SetDirectionUpLeft
    cmp dl, 'E'   ; Up-right
    je SetDirectionUpRight
    cmp dl, 'Z'   ; Down-left
    je SetDirectionDownLeft
    cmp dl, 'C'   ; Down-right
    je SetDirectionDownRight
    jmp CheckIfSpacePressed

    SetDirectionUp:
    mov direction, 'w'
    jmp CheckIfSpacePressed
    
    SetDirectionDown:
    mov direction, 'x'
    jmp CheckIfSpacePressed

    SetDirectionLeft:
    mov direction, 'a'
    jmp CheckIfSpacePressed

    SetDirectionRight:
    mov direction, 'd'
    jmp CheckIfSpacePressed

    SetDirectionUpLeft:
    mov direction, 'q'
    jmp CheckIfSpacePressed

    SetDirectionUpRight:
    mov direction, 'e'
    jmp CheckIfSpacePressed

    SetDirectionDownLeft:
    mov direction, 'z'
    jmp CheckIfSpacePressed

    SetDirectionDownRight:
    mov direction, 'c'
    jmp CheckIfSpacePressed
    
    mov al,1
    cmp al,bullet.exists
    je ExitFunc

CheckIfSpacePressed:
    cmp dl,' '
    je fireTheBullet
    jmp ExitFunc

fireTheBullet:
    call fire
    jmp ExitFunc

ExitFunc:
    ret
CheckIfBulletFired ENDP

fire PROC
    mov al, direction
    mov bl, player1.xPos
    mov bullet.xPos, bl
    inc bullet.xPos
    mov bl, player1.yPos
    mov bullet.yPos, bl
    inc bullet.yPos

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

    jmp exitFunc

fire_up:  
    mov xDir, 0
    mov yDir, -1
    jmp moveTheBullet
fire_down:   
    mov xDir, 0
    mov yDir, 1
    jmp moveTheBullet

fire_left:   
    mov xDir, -1
    mov yDir, 0
    jmp moveTheBullet

fire_right:
    mov xDir, 1
    mov yDir, 0
    jmp moveTheBullet

fire_upleft:    
    mov xDir, -1
    mov yDir, -1
    jmp moveTheBullet

fire_upright:
    mov xDir, 1
    mov yDir, -1
    jmp moveTheBullet

fire_downleft:
    mov xDir, -1
    mov yDir, 1
    jmp moveTheBullet

fire_downright:
    mov xDir, 1
    mov yDir, 1
    
moveTheBullet:
    mov bullet.exists,1     ; set bullet exists to true
    ret
exitFunc:
    ret
fire ENDP

moveBullet PROC
    cmp bullet.exists,0
    je exitFunc     ; dont move bullet if it doesnt exist
    
    mov dl,bullet.xPos
    mov dh,bullet.yPos
    call gotoxy
    mov al,' '
    call writeChar
    add dl,xDir
    add dl,xDir
    add dh,yDir
    add dh,yDir
    mov bullet.xPos,dl
    mov bullet.yPos,dh

    call gotoxy
    mov al,bullet.sprite
    call writeChar
        
    cmp dl, 20                ; Left boundary
    jle EndBullet
    cmp dl, 96                ; Right boundary
    jge EndBullet
    cmp dh, 5                 ; Top boundary
    jle EndBullet
    cmp dh, 27                ; Bottom boundary
    jge EndBullet

    ret

EndBullet:
    mov bullet.exists, 0        ; If reached out of bounds make bullet exists false
    mov dl, bullet.xPos
    mov dh, bullet.yPos
    call GoToXY
    mWrite " "                 ; Erase bullet from screen
    mov dx, 0
    ret
    
    exitFunc:

    
    ret
moveBullet ENDP

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
	mov eax,lightgreen
	call setTextColor
	call writeString
	call crlf
    
; Start button
    mov dl,0 
	mov dh,10
	call gotoxy
    mov edx,OFFSET start   
	mov eax,lightblue
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
	mov eax,red
	call setTextColor
	call writeString
	call crlf
    mov eax,brown
	call setTextColor
    ret
displayButtons ENDP

initializeGameScreen PROC
; Displaying score and title
LOCAL tmp1:BYTE
	mov dl,0
	mov dh,5

	mov eax,lightgreen (black * 16)
    call SetTextColor
	mwrite "SCORE: "
	
	mov temp1,eax
	mov eax,0
	mov al,score
	call writeInt
	mov eax,temp1

	mov eax,white (black * 16)
    call SetTextColor
    mov dl,15
    mov dh,29
    call Gotoxy
    mov edx,OFFSET border
    call WriteString
    mov dl,15
    mov dh,1
    call Gotoxy
    mov edx,OFFSET border
    call WriteString

    mov ecx,27
    mov dh,2
    mov tmp1,dh
    initializeBorder1:
        mov dh,tmp1
		mov dl,15
		call Gotoxy
		mov edx,OFFSET border1
		call WriteString
        inc tmp1
		LOOP initializeBorder1

    mov ecx,27
    mov dh,2
    mov temp,dh

    initializeBorder2:
		mov dh,temp
		mov dl,99
		call Gotoxy
		mov edx,OFFSET border2
		call WriteString
		inc temp
		LOOP initializeBorder2
   ret
initializeGameScreen ENDP

initializeGame PROC
    call displayButtons

CheckKeyInputs:
    call DetectKeyInput
    cmp bl,2
    jne CheckKeyInputs
	call Clrscr 
    
    call inputPlayerName
    call ClrScr
    call initializeGameScreen
	ret
initializeGame ENDP

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
    add leftBoundary,2
    sub rightBoundary,2
    add upperBoundary,2
    sub lowerBoundary,2

    ENDUPDATE:

	ret
UpdateBallChain ENDP

RUN_ZUMA PROC
    lea eax, menuMusic
    call playMenuMusic
	call initializeGame
	call DrawPlayer
    call DrawBallChain
    lea eax,gameMusic
    call playGameMusic
	gameLoop:      
        call HandleInput
        call moveBullet
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


%
end