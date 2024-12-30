// ========================================

#importonce

#import "../labels.asm"
#import "../constants.asm"
#import "keyboard.asm"
#import "util.asm"
#import "commands.asm"

// ========================================

.label screenMemStart       = $0400

.label tmpPointer           = $FC       // WORD $FC + $FD = used by PRINT_STRING
.label tmpCursor            = $FE       // WORD $FE + $FF = current pos in screen mem

.label curPosX              = $8000
.label curPosY              = $8001
.label cursorChar           = $8002

.label inpBufLen     	    = $8005
.label inpBufCur            = $8006

// ========================================

terminalOutputBuffer: .fill screenWidth - 1, $00

// ========================================

welcomeMessageLine1: .text @"*** 65-o-fun v0.1 BIOS ***\$00"
welcomeMessageLine2: .text @"created by y0014984 (c) 2024\$00"
welcomeMessageLine3: .text @"type 'help' for command list\$00"

// ========================================

initTerminal:
    lda #asciiSpace
    jsr fillScreen

    lda #7                                  // print welcome screen and prompt
    sta curPosX
    lda #1
    sta curPosY
    ldx #<welcomeMessageLine1
    ldy #>welcomeMessageLine1
    jsr printString

    lda #6
    sta curPosX
    lda #3
    sta curPosY
    ldx #<welcomeMessageLine2
    ldy #>welcomeMessageLine2
    jsr printString

    lda #6
    sta curPosX
    lda #5
    sta curPosY
    ldx #<welcomeMessageLine3
    ldy #>welcomeMessageLine3
    jsr printString

    lda #0
    sta curPosX
    lda #7
    sta curPosY

!return:
    rts

// ========================================

terminalStart:
    jsr initTerminal

!prompt:
    jsr resetInpBuf
    lda #asciiGreaterThan                   // prompt
    jsr printChar
    jsr incrCursor
    lda #asciiCursor                        // unused ASCII code is now Cursor
    jsr printChar
    lda #asciiSpace         
    sta cursorChar
!terminalLoop:
    jsr getCharFromBuf
    cmp #$00
    beq !terminalLoop-
    cmp #$08                                // ASCII BACKSPACE
    beq !backspaceJump+
    cmp #$0A                                // ASCII LINE FEED
    beq !enterJump+
    cmp #$11                                // ASCII DEVICE CONTROL 1 = ARROW LEFT
    beq !arrowLeftJump+
    cmp #$12                                // ASCII DEVICE CONTROL 2 = ARROW RIGHT
    beq !arrowRightJump+
    jmp !jumpTableEnd+
!backspaceJump:
    jmp !backspace+
!enterJump:
    jmp !enter+
!arrowLeftJump:
    jmp !arrowLeft+
!arrowRightJump:
    jmp !arrowRight+
!jumpTableEnd:
    ldx curPosX                             // don't leave current input line
    cpx #screenWidth - 1
    beq !terminalLoop-

    ldx inpBufCur                           // increment input buffer/cursor
    cpx inpBufLen
    bne !noInpBufIncr+
    inc inpBufLen
!noInpBufIncr:
    inc inpBufCur

    jsr printChar
    jsr incrCursor
    jsr getCharOnCurPos
    bne !storeChar+
    lda #asciiSpace                         // use ASCII SPACE instead of $00/CURSOR to store
!storeChar:
    sta cursorChar
!printCursor:
    lda #asciiCursor                        // unused ASCII code is now Cursor
    jsr printChar
    jmp !terminalLoop-
!backspace:
    ldx curPosX                             // don't go beyond prompt
    cpx #1
    beq !jmpLoop+

    ldx inpBufCur                           // decrement input buffer/cursor
    cpx inpBufLen
    bne !noInpBufDecr+
    dec inpBufLen
!noInpBufDecr:
    dec inpBufCur

    lda cursorChar
    jsr printChar
    jsr decrCursor
    lda #asciiSpace
    sta cursorChar
    jsr printChar                           // override current pos with blank to clear cursor
    jmp !printCursor-
!jmpLoop:
    jmp !terminalLoop-
!enter:
    jsr processInpBuf
    jsr newTerminalLine
!enterContinue:
    jmp !prompt-
!arrowLeft:
    ldx curPosX                             // don't go beyond prompt
    cpx #1
    beq !jmpLoop-

    dec inpBufCur                           // decrement input cursor

    lda cursorChar
    jsr printChar
    jsr decrCursor
    jsr getCharOnCurPos
    sta cursorChar
    jmp !printCursor-
!arrowRight:
    ldx inpBufLen                           // don't leave input buffer
    inx                                     // + 1 for prompt
    cpx curPosX
    beq !jmpLoop-

    ldx inpBufCur                           // increment input cursor
    cpx inpBufLen
    beq !noInpCurIncr+
    inc inpBufCur
!noInpCurIncr:

    lda cursorChar
    jsr printChar
    jsr incrCursor
    jsr getCharOnCurPos
    cmp #$00                                // don't exceed beyond already printed chars
    beq !outsideInputString+                // which is the end of the current input string
    sta cursorChar
    jmp !printCursor-
!outsideInputString:
    jsr decrCursor
    jmp !printCursor-

// ========================================

resetInpBuf:
    lda #0                                  // reset input buffer
    sta inpBufLen
    sta inpBufCur
    ldx #0
!loop:
    sta terminalOutputBuffer,x
    inx
    cpx #screenWidth - 1
    bne !loop-
!return:
    rts

// ========================================

commandNotFound: .text @"Command not found\$00"

commandList:
bono: .text @"bono\$00"
cd: .text @"cd\$00"
clear: .text @"clear\$00"
date: .text @"date\$00"
echo: .text @"echo\$00"
help: .text @"help\$00"
ls: .text @"ls\$00"
mkdir: .text @"mkdir\$00"
pwd: .text @"pwd\$00"
rm: .text @"rm\$00"
rmdir: .text @"rmdir\$00"
touch: .text @"touch\$00"
uname: .text @"uname\$00"

.byte $00

processInpBuf:
    lda #asciiSpace
    jsr printChar

!echo:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda echo,Y
    cmp #$00
    beq !jsrEcho+
    stx curPosX
    jsr getCharOnCurPos
    cmp echo,Y
    bne !uname+
    inx
    iny
    jmp !loop-
!jsrEcho:
    jsr echoCommand
    jmp !return+

!uname:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda uname,Y
    cmp #$00
    beq !jsrUname+
    stx curPosX
    jsr getCharOnCurPos
    cmp uname,Y
    bne !date+
    inx
    iny
    jmp !loop-
!jsrUname:
    jsr unameCommand
    jmp !return+

!date:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda date,Y
    cmp #$00
    beq !jsrDate+
    stx curPosX
    jsr getCharOnCurPos
    cmp date,Y
    bne !help+
    inx
    iny
    jmp !loop-
!jsrDate:
    jsr dateCommand
    jmp !return+

!help:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda help,Y
    cmp #$00
    beq !jsrHelp+
    stx curPosX
    jsr getCharOnCurPos
    cmp help,Y
    bne !ls+
    inx
    iny
    jmp !loop-
!jsrHelp:
    jsr helpCommand
    jmp !return+

!ls:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda ls,Y
    cmp #$00
    beq !jsrLs+
    stx curPosX
    jsr getCharOnCurPos
    cmp ls,Y
    bne !cd+
    inx
    iny
    jmp !loop-
!jsrLs:
    jsr lsCommand
    jmp !return+

!cd:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda cd,Y
    cmp #$00
    beq !jsrCd+
    stx curPosX
    jsr getCharOnCurPos
    cmp cd,Y
    bne !pwd+
    inx
    iny
    jmp !loop-
!jsrCd:
    jsr cdCommand
    jmp !return+

!pwd:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda pwd,Y
    cmp #$00
    beq !jsrPwd+
    stx curPosX
    jsr getCharOnCurPos
    cmp pwd,Y
    bne !mkdir+
    inx
    iny
    jmp !loop-
!jsrPwd:
    jsr pwdCommand
    jmp !return+

!mkdir:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda mkdir,Y
    cmp #$00
    beq !jsrMkdir+
    stx curPosX
    jsr getCharOnCurPos
    cmp mkdir,Y
    bne !rmdir+
    inx
    iny
    jmp !loop-
!jsrMkdir:
    jsr mkdirCommand
    jmp !return+

!rmdir:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda rmdir,Y
    cmp #$00
    beq !jsrRmdir+
    stx curPosX
    jsr getCharOnCurPos
    cmp rmdir,Y
    bne !touch+
    inx
    iny
    jmp !loop-
!jsrRmdir:
    jsr rmdirCommand
    jmp !return+

!touch:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda touch,Y
    cmp #$00
    beq !jsrTouch+
    stx curPosX
    jsr getCharOnCurPos
    cmp touch,Y
    bne !rm+
    inx
    iny
    jmp !loop-
!jsrTouch:
    jsr touchCommand
    jmp !return+

!rm:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda rm,Y
    cmp #$00
    beq !jsrRm+
    stx curPosX
    jsr getCharOnCurPos
    cmp rm,Y
    bne !bono+
    inx
    iny
    jmp !loop-
!jsrRm:
    jsr rmCommand
    jmp !return+

!bono:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda bono,Y
    cmp #$00
    beq !jsrBono+
    stx curPosX
    jsr getCharOnCurPos
    cmp bono,Y
    bne !clear+
    inx
    iny
    jmp !loop-
!jsrBono:
    jsr bonoCommand
    jmp !return+

!clear:
    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda clear,Y
    cmp #$00
    beq !jsrClear+
    stx curPosX
    jsr getCharOnCurPos
    cmp clear,Y
    bne !commandNotFound+
    inx
    iny
    jmp !loop-
!jsrClear:
    jsr clearCommand
    jmp !return+

!commandNotFound:
    ldx #<commandNotFound
    ldy #>commandNotFound
    jsr printTerminalLine

!return:
    rts

// ========================================

// calculate current cur pos

// Affects: A, Y
// Preserves: X

calcCurPos:
    lda #<screenMemStart
    sta tmpCursor
    lda #>screenMemStart
    sta tmpCursor + 1

    ldy curPosY
!addY:                                  // loop through all rows and
    cpy #0                              // at the end add current x
    beq !addX+                          // to get current cursor
    lda tmpCursor
    clc
    adc #screenWidth                    // add screen width to cursor
    sta tmpCursor
    lda tmpCursor + 1
    adc #0
    sta tmpCursor + 1
    dey 
    jmp !addY-
!addX:
    lda tmpCursor
    clc
    adc curPosX                         // add x to cursor
    sta tmpCursor
    lda tmpCursor + 1
    adc #0
    sta tmpCursor + 1
!return:
    rts

// ========================================

// print char stored in A to screen

// Affects: X
// Preserves: A, Y

printChar:
    pha                                 // store A to stack
    jsr calcCurPos
!print:
    pla                                 // get current char stored in A
    ldx #0
    sta (tmpCursor,x)                   // print char to screen
!return:
    rts

// ========================================

// prints the string with address $yyxx == $$hhll

// Affects: A, Y
// Preserves: X

printString:
    tya
    pha
    jsr calcCurPos
    pla
    tay
    stx tmpPointer
    sty tmpPointer + 1

    ldy #0
!loop:
    lda (tmpPointer),Y
    cmp #$00
    beq !return+
    sta (tmpCursor),Y                   // print char to screen
    iny
    jmp !loop-

!return:
    rts

// ========================================

// Affects: A
// Preserves: X, Y

newTerminalLine:
    lda #0                              // new line
    sta curPosX
    inc curPosY
    lda #screenHeight - 1
    cmp curPosY
    bne !return+
    jsr terminalScrollUp
    dec curPosY
!return:
    rts

// ========================================

// X and Y contain low byte and high byte of the zero terminated string

printTerminalLine:
    jsr newTerminalLine
    jsr printString
!return:
    rts

// ========================================

errNoSuchFileOrDir: .text @"No such file or directory\$00"
errNotDir: .text @"Not a directory\$00"
errIsDir: .text @"Is a directory\$00"
errMissingParam: .text @"Missing parameter\$00"
errDirExists: .text @"Directory exists\$00"
errFileExists: .text @"File exists\$00"
errDirNotEmpty: .text @"Directory not empty\$00"
errUnknownCommand: .text @"Unknown Command\$00"

errorUnknown: .text @"Unknown error\$00"

printError:
    cmp #errCodeMissingParam
    beq !errMissingParam+
    cmp #errCodeNoFileOrDir
    beq !errNoFileOrDir+
    cmp #errCodeNotDir
    beq !errNotDir+
    cmp #errCodeIsDir
    beq !errIsDir+
    cmp #errCodeDirExists
    beq !errDirExists+
    cmp #errCodeFileExists
    beq !errFileExists+
    cmp #errCodeDirNotEmpty
    beq !errDirNotEmpty+
    cmp #errCodeUnknownCom
    beq !errUnknownCommand+

    jmp !errorUnknown+

!errNoFileOrDir:
    ldx #<errNoSuchFileOrDir
    ldy #>errNoSuchFileOrDir
    jmp !printError+

!errNotDir:
    ldx #<errNotDir
    ldy #>errNotDir
    jmp !printError+

!errIsDir:
    ldx #<errIsDir
    ldy #>errIsDir
    jmp !printError+

!errMissingParam:
    ldx #<errMissingParam
    ldy #>errMissingParam
    jmp !printError+

!errDirExists:
    ldx #<errDirExists
    ldy #>errDirExists
    jmp !printError+

!errFileExists:
    ldx #<errFileExists
    ldy #>errFileExists
    jmp !printError+

!errDirNotEmpty:
    ldx #<errDirNotEmpty
    ldy #>errDirNotEmpty
    jmp !printError+

!errUnknownCommand:
    ldx #<errUnknownCommand
    ldy #>errUnknownCommand
    jmp !printError+

!errorUnknown:
    ldx #<errorUnknown
    ldy #>errorUnknown

!printError:
    jsr printTerminalLine

!return:
    rts

// ========================================

// Affects: A
// Preserves: XY

tmpCharOnCurPos: .byte $00

getCharOnCurPos:
    tya
    pha
    jsr calcCurPos
    pla
    tay
!getChar:
    txa
    pha
    ldx #0
    lda (tmpCursor,x)                   // get char from current cursor position
    sta tmpCharOnCurPos
    pla
    tax
    lda tmpCharOnCurPos
!return:
    rts

// ========================================

incrCursor:

// Affects: X, Y
// Preserves: A

!incX:
    inc curPosX                         // set cur pos to next pos
    ldx curPosX
    cpx #screenWidth                    // screen width reached?
    beq !incY+
    jmp !return+
!incY:
    ldx #0
    stx curPosX                         // set pos x to 0
    inc curPosY                         // increment pos y
    ldy curPosY
    cpy #screenHeight                   // screen height reached?
    beq !reset+
    jmp !return+
!reset:
    ldy #0
    sty curPosY                         // set pos y to 0
!return:
    rts

// ========================================

decrCursor:

// Affects: XY
// Preserves: A

!decX:
    dec curPosX                         // set cur pos to previous pos
    ldx curPosX
    cpx #255                            // left screen border reached?
    beq !decY+
    jmp !return+
!decY:
    ldx #screenWidth - 1
    stx curPosX                         // set pos x to screen width
    dec curPosY                         // decrement pos y
    ldy curPosY
    cpy #255                            // upper screen border reached?
    beq !reset+
    jmp !return+
!reset:
    ldy #screenHeight - 1
    sty curPosY                         // set pos y to screen height
!return:
    rts

// ========================================

// Affects: A
// Preserves: X, Y

terminalScrollUp:
    lda #<screenMemStart + screenWidth
    sta sourceAddr
    lda #>screenMemStart + screenWidth
    sta sourceAddr + 1

    lda #<screenMemStart
    sta destinationAddr
    lda #>screenMemStart
    sta destinationAddr + 1

    tya
    pha
    ldy #0
!loop:
    lda (sourceAddr),Y
    sta (destinationAddr),Y

    lda #<sourceAddr                   // increment source address
    jsr incrZeropageAddr

    lda #<destinationAddr              // increment destination address
    jsr incrZeropageAddr

    lda sourceAddr + 1            // check if end of screen mem reached
    cmp #>(screenMemStart + (screenWidth * screenHeight))
    bne !loop-
    lda sourceAddr
    cmp #<(screenMemStart + (screenWidth * screenHeight))
    bne !loop-

!return:
    pla
    tay
    rts

// ========================================

// Fills the screen with an ASCII character
// A: ASCII character

// Affects: A, X, Y

fillScreen:
    tax                                 // store ASCII character to X
    lda #<screenMemStart
    sta destinationAddr
    lda #>screenMemStart
    sta destinationAddr + 1

    ldy #0
!loop:
    txa                                 // retrieve ASCII character from X
    sta (destinationAddr),Y            // store ASCII character to screen mem start

    lda #<destinationAddr              // increment destination address
    jsr incrZeropageAddr

    lda destinationAddr + 1            // check if end of screen mem reached
    cmp #>(screenMemStart + (screenWidth * screenHeight))
    bne !loop-
    lda destinationAddr
    cmp #<(screenMemStart + (screenWidth * screenHeight))
    bne !loop-
!return:
    rts

// ======================================== */