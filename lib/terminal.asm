 // ========================================

.label screenMemStart       = $0400

.const screenWidth          = 40        // 40 chars width * 8 = 320px
.const screenHeight         = 30        // 30 chars height * 8 = 240px

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

echo: .text @"echo\$00"

processInpBuf:
    lda #asciiSpace
    jsr printChar

    ldx #1                              // the current input buffer is in line curPosY after
    ldy #0                              // the prompt and has the length inpBufLen
!loop:
    lda echo,Y
    cmp #$00
    beq !echo+
    stx curPosX
    jsr getCharOnCurPos
    cmp echo,Y
    bne !commandNotFound+
    inx
    iny
    jmp !loop-
!commandNotFound:
    ldx #<commandNotFound
    ldy #>commandNotFound
    jsr printTerminalLine
    jmp !return+
!echo:
    jsr echoCommand
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

// print char stored in A to screen and increment cursor

// Affects: X
// Preserves: A, Y

printChar:
    pha                                 // store A to stack
    jsr calcCurPos
!print:
    pla                                 // get current char stored in A
    ldx #0
    sta (tmpCursor,X)                   // print char to screen
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
    lda (tmpCursor,X)                   // get char from current cursor position
    sta tmpCharOnCurPos
    pla
    tax
    lda tmpCharOnCurPos
!return:
    rts

// ========================================

incrCursor:

// Affects: XY
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