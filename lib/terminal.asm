// ========================================

#importonce

#import "../labels.asm"
#import "../constants.asm"
#import "keyboard.asm"
#import "util.asm"
#import "commands.asm"

// ========================================

.namespace terminal {

// ========================================

.label pointer              = $FC           // WORD $FC + $FD = used by PRINT_STRING
.label cursor               = $FE           // WORD $FE + $FF = current pos in screen mem

.label curPosX              = $0340
.label curPosY              = $0341
.label cursorChar           = $0342

.label inpBufLen     	    = $0343
.label inpBufCur            = $0344

// ========================================

outputBuffer: .fill screenWidth - 1, $00

// ========================================

welcomeMessageLine1: .text @"*** 65-o-fun v0.1 BIOS ***\$00"
welcomeMessageLine2: .text @"created by y0014984 (c) 2024\$00"
welcomeMessageLine3: .text @"type 'help' for command list\$00"

// ========================================

colorTable1:
    // Values in RGBA
    .byte 0, 0, 0, 255                      // color 0 (black)
    .byte 255, 255, 255, 255                // color 1 (white)

colorTable2:
    // Values in RGBA
    .byte 255, 255, 255, 255                // color 0 (white)
    .byte 0, 0, 0, 255                      // color 1 (black)

// ========================================

initGraphics:
    lda #colMode2
    sta colorMode

    lda #<colorTable1
    sta colorTableAddr
    lda #>colorTable1
    sta colorTableAddr+1

    lda #tileMode8 | (tileOrientLeftRight << 7)
    sta tileModeOrientation

    lda #screenWidth
    sta tileMapWidth

    lda #screenHeight
    sta tileMapHeight

    lda #<screenMemStart
    sta tileMapAddr
    lda #>screenMemStart
    sta tileMapAddr+1

    lda #<fontStart
    sta tileSetAddr
    lda #>fontStart
    sta tileSetAddr+1
    
    lda #255
    sta tileSetLength

!return:
    rts
    
// ========================================

init:
    jsr initGraphics

    lda #charSpace
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

start:
    jsr init

!loop:
    lda #charGreaterThan                   // prompt
    jsr printChar
    jsr incrCursor

    jsr getString
    jsr processInpBuf
    jsr newTerminalLine
    jmp !loop-

// ========================================

getStringStart: .byte $00

getString:
    lda curPosX
    sta getStringStart

    jsr resetInpBuf
    lda #charFullBlock                     // unused ASCII code is now Cursor
    jsr printChar
    lda #charSpace         
    sta cursorChar
!getStringLoop:
    jsr getCharFromBuf
    cmp #$00
    beq !getStringLoop-
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
    beq !getStringLoop-

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
    lda #charSpace                          // use ASCII SPACE instead of $00/CURSOR to store
!storeChar:
    sta cursorChar
!printCursor:
    lda #charFullBlock                      // unused ASCII code is now Cursor
    jsr printChar
    jmp !getStringLoop-
!backspace:
    ldx curPosX                             // don't go beyond getStringStart
    cpx getStringStart
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
    lda #charSpace
    sta cursorChar
    jsr printChar                           // override current pos with blank to clear cursor
    jmp !printCursor-
!jmpLoop:
    jmp !getStringLoop-
!enter:
    jmp !return+
!arrowLeft:
    ldx curPosX                             // don't go beyond getStringStart
    cpx getStringStart
    beq !jmpLoop-

    dec inpBufCur                           // decrement input cursor

    lda cursorChar
    jsr printChar
    jsr decrCursor
    jsr getCharOnCurPos
    sta cursorChar
    jmp !printCursor-
!arrowRight:
    lda inpBufLen                           // don't leave input buffer
    clc
    adc getStringStart
    cmp curPosX
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
!return:
    rts

// ========================================

resetInpBuf:
    lda #0                                  // reset input buffer
    sta inpBufLen
    sta inpBufCur
    ldx #0
!loop:
    sta outputBuffer,x
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
run: .text @"run\$00"
touch: .text @"touch\$00"
uname: .text @"uname\$00"

.byte $00

processInpBuf:
    lda #charSpace
    jsr printChar

!echo:
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
!loop:
    lda bono,Y
    cmp #$00
    beq !jsrBono+
    stx curPosX
    jsr getCharOnCurPos
    cmp bono,Y
    bne !run+
    inx
    iny
    jmp !loop-
!jsrBono:
    jsr bonoCommand
    jmp !return+

!run:
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
!loop:
    lda run,Y
    cmp #$00
    beq !jsrRun+
    stx curPosX
    jsr getCharOnCurPos
    cmp run,Y
    bne !clear+
    inx
    iny
    jmp !loop-
!jsrRun:
    jsr runCommand
    jmp !return+

!clear:
    ldx #1                                  // the current input buffer is in line curPosY after
    ldy #0                                  // the prompt and has the length inpBufLen
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
    jsr printLine

!return:
    rts

// ========================================

// calculate current cur pos and stores it
// in cursor (ZP) as a memory location

// Affects: A, Y
// Preserves: X

calcCurPos:
    lda #<screenMemStart
    sta cursor
    lda #>screenMemStart
    sta cursor + 1

    ldy curPosY
!addY:                                      // loop through all rows and
    cpy #0                                  // at the end add current x
    beq !addX+                              // to get current cursor
    lda cursor
    clc
    adc #screenWidth                        // add screen width to cursor
    sta cursor
    lda cursor + 1
    adc #0
    sta cursor + 1
    dey 
    jmp !addY-
!addX:
    lda cursor
    clc
    adc curPosX                             // add x to cursor
    sta cursor
    lda cursor + 1
    adc #0
    sta cursor + 1
!return:
    rts

// ========================================

// print char stored in A to screen

// Affects: X
// Preserves: A, Y

printChar:
    pha                                     // store A to stack
    jsr calcCurPos
!print:
    pla                                     // get current char stored in A
    ldx #0
    sta (cursor,x)                          // print char to screen
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
    stx pointer
    sty pointer + 1

    ldy #0
!loop:
    lda (pointer),Y
    cmp #$00
    beq !return+
    sta (cursor),Y                          // print char to screen
    iny
    jmp !loop-

!return:
    rts

// ========================================

// Affects: A
// Preserves: X, Y

newTerminalLine:
    lda #0                                  // new line
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

printLine:
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
    jsr printLine

!return:
    rts

// ========================================

// Affects: A
// Preserves: XY

charOnCurPos: .byte $00

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
    lda (cursor,x)                          // get char from current cursor position
    sta charOnCurPos
    pla
    tax
    lda charOnCurPos
!return:
    rts

// ========================================

incrCursor:

// Affects: X, Y
// Preserves: A

!incX:
    inc curPosX                             // set cur pos to next pos
    ldx curPosX
    cpx #screenWidth                        // screen width reached?
    beq !incY+
    jmp !return+
!incY:
    ldx #0
    stx curPosX                             // set pos x to 0
    inc curPosY                             // increment pos y
    ldy curPosY
    cpy #screenHeight                       // screen height reached?
    beq !reset+
    jmp !return+
!reset:
    ldy #0
    sty curPosY                             // set pos y to 0
!return:
    rts

// ========================================

decrCursor:

// Affects: XY
// Preserves: A

!decX:
    dec curPosX                             // set cur pos to previous pos
    ldx curPosX
    cpx #255                                // left screen border reached?
    beq !decY+
    jmp !return+
!decY:
    ldx #screenWidth - 1
    stx curPosX                             // set pos x to screen width
    dec curPosY                             // decrement pos y
    ldy curPosY
    cpy #255                                // upper screen border reached?
    beq !reset+
    jmp !return+
!reset:
    ldy #screenHeight - 1
    sty curPosY                             // set pos y to screen height
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

    lda #<sourceAddr                        // increment source address
    jsr incrZeropageAddr

    lda #<destinationAddr                   // increment destination address
    jsr incrZeropageAddr

    lda sourceAddr + 1                      // check if end of screen mem reached
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
    tax                                     // store ASCII character to X
    lda #<screenMemStart
    sta destinationAddr
    lda #>screenMemStart
    sta destinationAddr+1

    ldy #0
!loop:
    txa                                     // retrieve ASCII character from X
    sta (destinationAddr),Y                 // store ASCII character to screen mem start

    lda #<destinationAddr                   // increment destination address
    jsr incrZeropageAddr

    lda destinationAddr+1                   // check if end of screen mem reached
    cmp #>(screenMemStart+(screenWidth*screenHeight))
    bne !loop-
    lda destinationAddr
    cmp #<(screenMemStart+(screenWidth*screenHeight))
    bne !loop-
!return:
    rts

// ======================================== */

} // end of Namespace

// ======================================== */