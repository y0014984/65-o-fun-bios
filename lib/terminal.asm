// ========================================

#importonce

#import "../labels.asm"
#import "../constants.asm"
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

commandNotFound: .text @"Command not found\$00"

commandList:
echo: .text @"echo\$00"
uname: .text @"uname\$00"
date: .text @"date\$00"
help: .text @"help\$00"
ls: .text @"ls\$00"
cd: .text @"cd\$00"
pwd: .text @"pwd\$00"

/* history: .text @"history\$00"
shutdown: .text @"shutdown\$00"
mkdir: .text @"mkdir\$00"
rmdir: .text @"rmdir\$00" */

clear: .text @"clear\$00"
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
    bne !clear+
    inx
    iny
    jmp !loop-
!jsrPwd:
    jsr pwdCommand
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

newLine:
    lda #0                              // new line
    sta curPosX
    inc curPosY
    lda #screenHeight - 1
    cmp curPosY
    bne !return+
    jsr scrollUp
    dec curPosY
!return:
    rts

// ========================================

// X and Y contain low byte and high byte of the zero terminated string

printTerminalLine:
    jsr newLine
    jsr printString
!return:
    rts

// ========================================

errorUnknown: .text @"Unknown error\$00"
errorNoSuchFileOrDir: .text @"No such file or directory\$00"
errorNotDir: .text @"Not a directory\$00"

printError:
    cmp #errNoFileOrDir
    beq !errNoFileOrDir+
    cmp #errNotDir
    beq !errNotDir+
    jmp !unknownError+

!errNoFileOrDir:
    ldx #<errorNoSuchFileOrDir
    ldy #>errorNoSuchFileOrDir
    jmp !printError+

!errNotDir:
    ldx #<errorNotDir
    ldy #>errorNotDir
    jmp !printError+

!unknownError:
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

scrollUp:
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