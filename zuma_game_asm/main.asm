INCLUDE irvine32.inc
INCLUDE macros.inc
INCLUDELIB winmm.lib

mciSendString PROTO :PTR BYTE, :PTR BYTE, :DWORD, :DWORD
PlaySound PROTO, pszSound:PTR BYTE, hmod:DWORD, fdwSound:DWORD

.data
    menuMusic BYTE "F:\zuma_game_asm\zuma_game_asm\menu.wav", 0   ; Define the file name for the menu sound
    gameMusic BYTE "F:\zuma_game_asm\zuma_game_asm\game.wav", 0   ; Define the file name for the menu sound
    level1music BYTE "F:\zuma_game_asm\zuma_game_asm\level1.wav", 0   ; Define the file name for the menu sound
    level2music BYTE "F:\zuma_game_asm\zuma_game_asm\level2.wav", 0   ; Define the file name for the menu sound
    level3music BYTE "F:\zuma_game_asm\zuma_game_asm\level3.wav", 0   ; Define the file name for the menu sound
    combinationSound BYTE "F:\zuma_game_asm\zuma_game_asm\combinationsound.wav", 0   ; Define the file name for the menu sound
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
    BallChain Ball 120 dup(<'O',?,?,1,?>)
    bullet Ball <'O',?,?,0,?>

; Extra variables	
    playerName db 20 dup(?),0
    nameLength dd 0
    filehandle dword ?
	fileInput db 255 dup(?), 0
    filename db "Scores.txt",0
    append_str db 2 dup(?),0
    ballCount dd 1
    LevelComplete db 0
    LevelNotCleared db 0
    currentLevel dd 1
    revolutions db 0
    MAX_REVOLUTIONS db 6
    colorIndex dd 0
    colors db red,blue,green,yellow,white,cyan,magenta
    numColors dd 3
    lives db 3
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

    upperBoundary db 6
    leftBoundary db 40
    lowerBoundary db 20
    rightBoundary db 80

    bulletupperBoundary db 1
    bulletleftBoundary db 38
    bulletlowerBoundary db 22
    bulletrightBoundary db 82
	
; Characters representing rotations
    up_char db '^'
    down_char db 'v'
    left_char db '<'
    right_char db '>'
    end_char db '~'
    end_x db ?
    end_y db ?

    ; Default character (initial direction)
    current_char db '^'

	; Colors for the emitter and player
    ; fire_color db 14     ; Fire symbol color (Yellow)

    ; Emitter properties
    ballchain_y db 4    ; Two rows above player (fixed row for emitter)
    ballchain_x db 80    ; Starting column of the emitter

    ; Fire symbol properties (fired from player)
    fire_row db 0        ; Fire will be fired from the player's position
    fire_col db 0        ; Initial fire column will be set in the update logic
    
    

	Zuma_art db "                                           ______   _ __  __    _           ", 0Ah
         db "                                   __/\__ |__  / | | |  \/  |  / \    __/\__", 0Ah
         db "                                   \    /   / /| | | | |\/| | / _ \   \    /", 0Ah
         db "                                   /_  _\  / /_| |_| | |  | |/ ___ \  /_  _\", 0Ah
         db "                                     \/   /____|\___/|_|  |_/_/   \_\   \/  ", 0Ah, 0

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
                               db' 2. Press SPACE to shoot a ball and try to match THREE or more balls together to destroy the chain',13,10
                               db' 3. Press P to pause the game                                                                    ',13,10
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

    GAME_OVER_SCREEN db '                           ____    _    __  __ _____    _____     _______ ____  ', 0DH,0AH
    db '                         / ___|  / \  |  \/  | ____|  / _ \ \   / / ____|  _ \ ', 0DH,0AH
    db '                        | |  _  / _ \ | |\/| |  _|   | | | \ \ / /|  _| | |_) |', 0DH,0AH
    db '                        | |_| |/ ___ \| |  | | |___  | |_| |\ V / | |___|  _ < ', 0DH,0AH
    db '                         \____/_/   \_\_|  |_|_____|  \___/  \_/  |_____|_| \_\\', 0DH,0AH,0



; --------------------------------------------------------------------------------------------------------------		

.code
StopMusic PROC
    invoke PlaySound, 0, 0, SND_PURGE
    ret
StopMusic ENDP

playMusic PROC
    push eax            
    push edx
    invoke PlaySound, eax, 0, SND_LOOP or SND_ASYNC
    pop edx
    pop eax
    ret                 
playMusic ENDP

DrawPlayer PROC
	mov player1.ypos,13
	mov player1.xpos,60
    mov bl,current_char
    mov player1.sprite,'@'
	mov dh,player1.ypos
	mov dl,player1.xpos
	call gotoxy

	mov eax,cyan
	call setTextColor
	mov al,player1.sprite
	call writeChar
    mov al,player1.xpos
    mov end_x,al
    add end_x,5
    mov al,player1.ypos
    mov end_y,al
    sub end_y,4

    mov dl,end_x
    mov dh,end_y
    call gotoxy
    mov al,red
    call setTextColor
    mov al,end_char
    ;call writeChar
	ret
DrawPlayer ENDP

instructionsMenu PROC USES eax edx
    call ClrScr
    mov eax,yellow
    call setTextColor
    mov edx,OFFSET INSTRUCTIONS_SCREEN
    call writeString
    call crlf
    mwrite "Press ESC to return to the menu..."

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
    mov eax,green
    call settextcolor
    lea edx,ZUMA_ART
    call writeString
    call crlf
    mwrite "ENTER YOUR NAME: "
    mov edx,OFFSET playerName
    mov ecx,20
    call readString
    mov nameLength,eax

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
    call stopMusic
    DetectKeyPress:
    mov eax,50
    call Delay
    call ReadKey
    cmp dl,VK_ESCAPE
    je ExitingPauseScreen
    jmp DetectKeyPress

    ExitingPauseScreen:
    cmp currentLevel,1
    je level1
    cmp currentLevel,2
    je level2
    jmp level3
level1:
    lea eax,level1music
    call playMusic
    jmp init
level2:
    lea eax,level2music
    call playMusic
    jmp init
level3:
    lea eax,level3music
    call playMusic
init:
    call ClrScr
    call updateScoreAndLives
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
    cmp dl,'O'
    je SkipLevel

    call CheckIfBulletFired     ; Check if bullet fired
    jmp ExitFunc

SkipLevel:
    mov levelComplete,1
    lea eax,combinationsound
    call playMusic
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

CheckIfSpacePressed:
; Check if bullet exists before checking input
    mov al,1
    cmp al,bullet.exists
    je ExitFunc
    
    cmp dl,' '
    je fireTheBullet
    jmp ExitFunc

fireTheBullet:
    mov dh,0
    mov dl,67
    call Gotoxy
    mov edi,colorIndex
    cmp edi,numColors
    je ResetIndex
    inc edi
    cmp edi,numColors
    je ResetIndex
    jmp PrintNextColor
ResetIndex:
    mov edi,0
PrintNextColor:
    mov eax,lightgreen
    call setTextColor
    mwrite "Bullet color:"
    movzx eax,colors[edi]
    call setTextColor
    mwrite "O"
    call fire
    jmp ExitFunc

ExitFunc:
    ret
CheckIfBulletFired ENDP

fire PROC
    mov al, direction
    mov bl, player1.xPos
    mov bullet.xPos, bl
    mov bl, player1.yPos
    mov bullet.yPos, bl

    mov ebx,colorIndex
    movzx edi,colors[ebx]
    mov bullet.ballColor,edi

    inc colorIndex
    mov ebx,colorIndex
    mov edx,numColors
    dec edx
    cmp ebx, edx
    jle SkipReset
    mov colorIndex, 0

SkipReset:
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
    dec bullet.yPos
    jmp moveTheBullet
fire_down:   
    mov xDir, 0
    mov yDir, 1
    inc bullet.yPos
    jmp moveTheBullet

fire_left:   
    mov xDir, -1
    mov yDir, 0
    dec bullet.xPos
    jmp moveTheBullet

fire_right:
    mov xDir, 1
    mov yDir, 0
    inc bullet.xPos
    jmp moveTheBullet

fire_upleft:    
    mov xDir, -1
    mov yDir, -1
    dec bullet.xPos
    dec bullet.yPos
    jmp moveTheBullet

fire_upright:
    mov xDir, 1
    mov yDir, -1
    inc bullet.xPos
    dec bullet.yPos
    jmp moveTheBullet

fire_downleft:
    mov xDir, -1
    mov yDir, 1
    dec bullet.xPos
    inc bullet.yPos
    jmp moveTheBullet

fire_downright:
    mov xDir, 1
    mov yDir, 1
    inc bullet.xPos
    inc bullet.yPos
    
moveTheBullet:
    
    mov bullet.exists,1     ; set bullet exists to true
    ret
exitFunc:
    ret
fire ENDP

moveBullet PROC USES eax
    cmp bullet.exists,0
    je exitFunc     ; dont move bullet if it doesnt exist
    
    mov dl,bullet.xPos
    mov dh,bullet.yPos
    call gotoxy
    mov al,' '
    call writeChar
    add dl,xDir
    add dh,yDir
    mov bullet.xPos,dl
    mov bullet.yPos,dh

    call gotoxy
    mov eax,bullet.ballColor
    call setTextColor
    mov eax,0
    mov al,bullet.sprite
    call writeChar
        
    cmp dl, bulletleftBoundary                ; Left boundary
    jle EndBullet
    cmp dl, bulletrightBoundary                ; Right boundary
    jge EndBullet
    cmp dh, bulletupperBoundary                ; Top boundary
    jle EndBullet
    cmp dh, bulletlowerBoundary                ; Bottom boundary
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

UpdateScoreAndLives PROC
    mov dl,15
	mov dh,0
    call Gotoxy

	mov eax,lightgreen (black * 16)
    call SetTextColor
; Level
    mov dl,10
    call Gotoxy
    mwrite "Level: "
    mov eax,currentLevel
    call writeInt
; Score
    mov dl,30
    call Gotoxy
	mwrite "Score: "
    mov temp1,eax
	movzx eax,score
	call writeInt
; Ball Count
    mov dl,49
    call Gotoxy
    mwrite "Ball Count:"
    mov eax,ballCount
    call WriteInt
	mov eax,temp1
; Lives 
    mov dl,90
    mov dh,0
    call Gotoxy
    mwrite "Lives: "
    mov dl,97
    call Gotoxy
    movzx eax,lives
    call writeInt
    call crlf
    ret
UpdateScoreAndLives ENDP

initializeGame PROC
; Display the screen
    call displayButtons

; Wait for user input
CheckKeyInputs:
    call DetectKeyInput
    cmp bl,2
    jne CheckKeyInputs
	call Clrscr 
    
; Go here if start button is pressed
    call inputPlayerName
    call ClrScr
    ;call initializeGameScreen
	ret
initializeGame ENDP

initializeBallChain PROC USES eax ecx esi
LOCAL currentColor:dword
mov currentColor,0
	mov dl, ballchain_x ; initial positions of the ball chain
    mov dh, ballchain_y
    mov ecx,ballCount
    mov esi,0
    
    Initialize: 
        mov edi,currentColor
        mov eax,currentColor
        mov ballChain[esi].xPos,dl
        mov ballChain[esi].yPos,dh   
        movzx ebx,colors[edi]
        mov ballChain[esi].ballColor,ebx
        inc currentColor
        mov ebx,numColors
        cmp currentColor,ebx
        je resetCurrentColorVar
        inc dl      
        add esi,SIZEOF Ball       
        LOOP Initialize
        
        jmp ExitFunc
        resetCurrentColorVar:
        mov currentColor,0
        inc dl      
        add esi,SIZEOF Ball       
        LOOP Initialize
        
ExitFunc:
    ret
initializeBallChain ENDP

DrawBallChain PROC USES eax edx ecx
    mov esi,0
    mov ecx,ballCount
    DrawLoop:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        mov eax,ballChain[esi].ballColor
        call setTextColor
        call Gotoxy
        mov al,ballChain[esi].sprite
        call WriteChar
        add esi,SIZEOF Ball
        LOOP DrawLoop
    ret
DrawBallChain ENDP

RestartLevel PROC
    call stopMusic
    call ClrScr
    call updateScoreAndLives
    call DrawPlayer
    call initializeBallChain
    call DrawBallChain
    lea eax,gameMusic
    call playMusic

    ret
RestartLevel ENDP

UpdateLoopBallChain PROC USES ecx
    LOCAL tmpX:BYTE
    LOCAL tmpY:BYTE
    LOCAL old_dl:BYTE
    LOCAL old_dh:BYTE
    
; Initial conditions
    mov esi,0
    mov ecx,ballCount
    cmp ecx,1
    je ifOneBall

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
    cmp ecx,0

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
ifOneBall:

    ret
UpdateLoopBallChain ENDP

UpdateBallChain1 PROC USES eax ecx edx
    LOCAL tmpX:BYTE
    LOCAL tmpY:BYTE
    cmp currentLevel,3
    je ENDUPDATE

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
        call DrawBallChain          ; redraws the updated version of the chain
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
        call DrawBallChain        ; redraws the updated version of the chain
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
        call DrawBallChain        ; redraws the updated version of the chain
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
        call DrawBallChain        ; redraws the updated version of the chain
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
    add upperBoundary,1
    sub lowerBoundary,1
    inc revolutions
    mov al,revolutions
    cmp al,MAX_REVOLUTIONS
    je maxRevsReached

ENDUPDATE:
	ret
maxRevsReached:
    cmp score,0
    jne NextLevel
    dec lives
    cmp lives,0
    je EndLevel
    ;call restartLevel
    ret
NextLevel:
    ; inc level
EndLevel:
    ;call ClrScr
    ret
UpdateBallChain1 ENDP

UpdateBallChain PROC USES eax ecx edx
    LOCAL tmpX:BYTE
    LOCAL tmpY:BYTE

    cmp currentLevel,3
    jne ENDUPDATE

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
    je MOVINGLEFTDOWN
    cmp al,3
    je MOVINGDOWN
    cmp al,4
    je MOVINGDOWNRIGHT
    cmp al,5
    je MOVINGRIGHT
    cmp al,6
    je MOVINGRIGHTUP
    cmp al,7
    je MOVINGUP
    cmp al,8
    je MOVINGUPLEFT

    mov dl,ballChain[esi].xPos
    mov dh,ballChain[esi].xPos
    cmp dl,5
    jle MOVINGDOWN
 
    MOVINGLEFT:    
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        dec dl ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain          ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        cmp dl,leftBoundary
        jg ENDUPDATE
        cmp currentLevel,3
        jne NotLevel3_1
        mov al,2 ; change direction to down left
        mov ballChainDirection,al
        jmp ENDUPDATE
    NotLevel3_1:
        mov al,3 ; change direction to down
        mov ballChainDirection,al
        jmp ENDUPDATE

    MOVINGLEFTDOWN:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        dec dl ; make the movement updation
        inc dh

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain          ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        mov bl,leftBoundary
        sub bl,8
        cmp dl,bl
        jg ENDUPDATE
        mov al,3 ; change direction to down
        mov ballChainDirection,al
        jmp ENDUPDATE
   
    MOVINGDOWN:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        inc dh ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dh,ballChain[esi].yPos
        cmp dh,lowerBoundary
        jl ENDUPDATE
        cmp currentLevel,3
        jne NotLevel3_2
        mov al,4 ; change direction to down right
        mov ballChainDirection,al
        jmp ENDUPDATE
        NotLevel3_2:
        mov al,5    ; right
        mov ballChainDirection,al
        jmp ENDUPDATE

     MOVINGDOWNRIGHT:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        inc dh ; make the movement updation
        inc dl

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dh,ballChain[esi].yPos
        mov bh,lowerBoundary
        add bh,7
        cmp dh,bh
        jl ENDUPDATE
        mov al,5 ; change direction to right
        mov ballChainDirection,al
        jmp ENDUPDATE

    MOVINGRIGHT:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        inc dl ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        cmp dl,rightBoundary
        jl ENDUPDATE
        cmp currentLevel,3
        jne notLevel3_3
        mov al,6 ; change direction to right up
        mov ballChainDirection,al
        jmp ENDUPDATE
    Notlevel3_3:
        mov al,7    ; up
        mov ballChainDirection,al
        jmp ENDUPDATE

    MOVINGRIGHTUP:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        inc dl ; make the movement updation
        dec dh ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        mov bl,rightBoundary
        add bl,8
        cmp dl,bl
        jl ENDUPDATE
        mov al,7 ; change direction to up
        mov ballChainDirection,al
        jmp ENDUPDATE

    MOVINGUP:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy

        dec dh ; make the movement updation

        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        cmp dh,upperBoundary
        jl ENDUPDATE
        cmp currentLevel,3
        jne notLevel3_4
        mov al,8
        mov ballChainDirection,al
        jmp ENDUPDATE

        notLevel3_4:
        jmp LoopSpiral

    MOVINGUPLEFT:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call gotoxy
        cmp upperBoundary,4
        jle LoopSpiral

        dec dh ; make the movement updation
        dec dl
        call UpdateLoopBallChain    ; updates the values of each of the balls accordingly
        call DrawBallChain        ; redraws the updated version of the chain
        mov esi,0
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        mov bh,upperBoundary
        
        sub bh,2
        cmp dh,bh
        jle LoopSpiral
        jmp ENDUPDATE

    LoopSpiral:
    mov al,1
    mov ballChainDirection,al
    add leftBoundary,1
    sub rightBoundary,2
    add upperBoundary,1
    sub lowerBoundary,1
    inc revolutions
    mov al,revolutions
    cmp al,MAX_REVOLUTIONS
    je maxRevsReached

ENDUPDATE:
	ret
maxRevsReached:
    cmp score,0
    jne NextLevel
    dec lives
    cmp lives,0
    je EndLevel
    ;call restartLevel
    ret
NextLevel:
    ; inc level
EndLevel:
    ;call ClrScr
    ret
UpdateBallChain ENDP

EraseBallChain PROC USES ecx esi
    mov ecx,ballCount
    mov esi,0
    Erase:
        mov dl,ballChain[esi].xPos
        mov dh,ballChain[esi].yPos
        call Gotoxy
        mov al,' '
        call writeChar
        add esi,SIZEOF Ball
        LOOP Erase
    ret
EraseBallChain ENDP

AddNewBallToChain PROC USES ecx edi esi
    mov esi,0                        ; Start at the base address of the ball chain
    mov ecx,ballCount                ; Load the number of balls
    dec ecx                           ; Calculate ballCount - 1 (index of the last ball)
    imul ecx,SIZEOF Ball             ; Multiply index by SIZEOF Ball to get the offset
    add esi,ecx                      ; Add the offset to the base address

    call EraseBallChain ; Erase the old ball Chain
    AddNewBall:
        cmp esi,edi
        jl InsertNewBall

        mov al,ballChain[esi].xPos
        mov ballChain[esi + SIZEOF Ball].xPos,al

        mov al,ballChain[esi].yPos
        mov ballChain[esi + SIZEOF Ball].yPos,al

        mov al,ballChain[esi].sprite
        mov ballChain[esi + SIZEOF Ball].sprite,al

        mov eax,ballChain[esi].ballColor
        mov ballChain[esi + SIZEOF Ball].ballColor,eax

        mov al,ballChain[esi].exists
        mov ballChain[esi + SIZEOF Ball].exists,al
        dec esi
        jmp AddNewBall   
    InsertNewBall:
    mov al,bullet.xPos   
    mov ballChain[edi].xPos,al
    mov al,bullet.yPos
    mov ballChain[edi].yPos,al
    mov al,bullet.sprite
    mov ballChain[edi].sprite,al
    mov eax,bullet.ballColor
    mov ballChain[edi].ballColor,eax
    mov al,1
    mov ballChain[edi].exists,al
    mov bullet.exists, 0 ; Mark bullet as non-existent
    inc ballCount
    ret
AddNewBallToChain ENDP

ShiftBalls PROC USES esi edi eax ebx ecx
    mov dh,2
    mov dl,0
    call Gotoxy
    mov eax,ebx
    call WriteInt
    mov ecx,ballCount
    sub ecx,ebx
    jecxz ExitFunc
    ShiftLoop:
        mov edi,esi
        imul eax,ebx,SIZEOF Ball
        sub edi,eax
        movzx eax,ballChain[esi].xPos
        mov ballChain[edi].xPos,al
        movzx eax,ballChain[esi].yPos
        mov ballChain[edi].xPos,al   
        movzx eax,ballChain[esi].exists
        mov ballChain[edi].exists,al
        mov eax,ballChain[esi].ballColor
        mov ballChain[edi].ballColor,eax       
        add esi,SIZEOF Ball
        Loop ShiftLoop

ExitFunc:
    ret
ShiftBalls ENDP

checkBallCombinations PROC USES edi ecx
; If 3 or more balls with the same color, remove all of them and increment score by the number of balls removed 

    LOCAL count:BYTE
    LOCAL ballColor:DWORD
    LOCAL tmpEAX:DWORD

    call EraseBallChain
    mov ecx,ballCount
    cmp ecx,2
    jbe ExitFunc
    
    mov esi,0
    mov edi,esi
    mov count,1
    mov eax,ballChain[esi].ballColor
    mov ballColor,eax       ; Initial color

    CheckCombinations:
        add esi,SIZEOF Ball
        dec ecx
        jz LastCheck
        
        mov eax,ballChain[esi].ballColor
        cmp eax,ballColor
        jne ProcessCombination
    
        inc count
        jmp CheckCombinations
    ProcessCombination:
        cmp count,3
        jb ResetCombination
        movzx ebx,count
        call ShiftBalls
        add score,bl
        sub ballCount,ebx
        cmp ballCount,0
        je NoBallsLeft
        imul eax,ebx,SIZEOF Ball
        sub esi,eax
        mov edi,esi

    ResetCombination:
        mov count,1
        mov eax,ballChain[esi].ballColor
        mov ballColor,eax
        jmp CheckCombinations
    
    LastCheck:
        cmp count,3
        jb ExitFunc
        movzx ebx,count
        call ShiftBalls
        add score,bl
        sub ballCount,ebx
        cmp ballCount,0
        je NoBallsLeft
        imul eax,ebx,SIZEOF Ball
        sub esi,eax
        mov edi,esi
ExitFunc:
    mov bl,1
    cmp ballCount,0
    je NoBallsLeft
    call DrawBallChain
    ret
NoBallsLeft:
    mov bl,0
    ret
checkBallCombinations ENDP

DetectCollisions PROC
    mov ecx,ballCount
    mov esi,0
    mov al,bullet.exists
    cmp al,0
    je NextCheckCollisionWithPlayer ; dont check collision if bullet doesnt exist
    
    CheckCollisionWithBullet:
        mov dl,bullet.xPos
        cmp dl,ballChain[esi].xPos
        jne NoCollision
        
        mov dh,bullet.yPos
        cmp dh,ballChain[esi].yPos
        jne NoCollision

        mov edi,esi
        call AddNewBallToChain      ; Add the new ball to the chain
        jmp NextCheckCollisionWithPlayer
    NoCollision:
        add esi,SIZEOF Ball
        LOOP CheckCollisionWithBullet

    NextCheckCollisionWithPlayer:    
        mov ecx,ballCount
        mov esi,0   
    CheckCollisionWithPlayer:
        mov dl,player1.xPos
        cmp dl,ballChain[esi].xPos
        jne NoCollision2
        
        mov dh,player1.yPos
        cmp dh,ballChain[esi].yPos
        jne NoCollision2
        
        mov levelNotCleared,1
        jmp ExitFunc
    NoCollision2:
        add esi,SIZEOF Ball
        LOOP CheckCollisionWithPlayer           
ExitFunc:
    ret
DetectCollisions ENDP

checkLevelComplete PROC
    mov eax,ballCount
    cmp eax,1
    jle LevelFinished

    ret
LevelFinished:
    mov levelComplete,1
    ret
checkLevelComplete ENDP

run PROC
    lea eax, menuMusic
    call playMusic
	call initializeGame
gameStart:
    mov eax,currentLevel
    mov ecx,eax
    cmp ecx,1
    je LevelOne
    cmp ecx,2
    je LevelTwo
    cmp ecx,3
    je LevelThree
    jmp ExitGame
LevelOne:
    mov upperBoundary,6
    mov leftBoundary,40
    mov lowerBoundary,20
    mov rightBoundary,80
    mov numColors,3
    mov ballCount,2
    lea eax,level1music
    call playMusic
    jmp InitializeLevel

LevelTwo:
    mov upperBoundary,6
    mov leftBoundary,40
    mov lowerBoundary,20
    mov rightBoundary,80
    mov numColors,5
    mov ballCount,10
    lea eax,level2music
    call playMusic
    jmp InitializeLevel

LevelThree:
    mov upperBoundary,6
    mov leftBoundary,30
    mov lowerBoundary,16
    mov rightBoundary,80
    mov bulletupperBoundary, 2
    mov bulletleftBoundary,21
    mov bulletlowerBoundary,24
    mov bulletrightBoundary,90
    mov numColors,8
    mov ballCount,30
    lea eax,level3music
    call playMusic
    jmp InitializeLevel

InitializeLevel:
    mov ballChainDirection,1
    call ClrScr
	call DrawPlayer
    call updateScoreAndLives
    call InitializeBallChain
    call DrawBallChain

gameLoop:     
    mov bl,1
    call HandleInput            ; Handle all inputs
    call moveBullet             ; Move bullet if exists
    call detectCollisions       ; Detect collisions between ball and chain
    call updateBallChain1        ; Update position of chain
    call updateBallChain        ; Update position of chain
    call checkBallCombinations  ; Check if combinations of three or more are created
    call checkLevelComplete
    cmp LevelComplete,1
    je NextLevel
    cmp levelNotCleared,1
    je ReduceLife

    call updateScoreAndLives    ; Update the score accordingly
	jmp GameLoop
ReduceLife:
    dec lives
    cmp lives,0
    je ExitGame
    mov levelNotCleared,0
    call ClrScr
    jmp gameStart
NextLevel:
    lea eax,combinationsound
    call playMusic
    mov eax,500
    call delay
    inc currentLevel
    mov levelComplete,0
    jmp gameStart

ExitGame:
    call stopMusic
    call ClrScr
    mov dh,11
    mov dl,0
    
    call gotoxy
    mov eax,red
    call setTextColor
    lea edx,GAME_OVER_SCREEN
    call writeString
    call crlf
    call waitMsg

    mov edx,OFFSET filename
	call createoutputfile
	mov filehandle,eax
	jc fileCreateError
	jmp exit1

	fileCreateError:
	mwrite "File not created"
	exit

	exit1:
	mov eax,filehandle
	mov edx,OFFSET playername
	mov ecx,nameLength
	call writetofile
	jc show_write_error
   
	jmp exit2

	show_write_error:
	call crlf
	mwrite "File not written"
	exit

	exit2:
	mov eax,filehandle
	call closefile
    ret
run ENDP

main PROC
	call run
	exit
main ENDP
end main