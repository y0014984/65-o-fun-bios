// Kick Assembler v5.25

.encoding "ascii"

// ========================================

#import "labels.asm"
#import "constants.asm"

// ========================================

.segmentdef Registers [start=$0200, virtual]
.segmentdef Buffers [start=$0300, virtual]
.segmentdef BIOS [start=biosStart, outPrg="bios.prg"]

// ========================================

.segment Registers                          // reserved 256 bytes

.fill 256, $00

// ========================================

.segment Buffers

.fill 256, $00

// ========================================

.segment BIOS

.memblock "Kernal"

    jsr initStorage

// ========================================

    //jsr testScreen
    //jsr testFontWrite
    //jsr testStorage

    jmp terminalStart

// ========================================

#import "lib/commands.asm"
#import "lib/keyboard.asm"
#import "lib/terminal.asm"
#import "lib/storage.asm"
#import "lib/test.asm"
#import "lib/util.asm"

// ========================================

welcomeMessageLine1: .text @"*** 65-o-fun v0.1 BIOS ***\$00"
welcomeMessageLine2: .text @"created by y0014984 (c) 2024\$00"

// ========================================

terminalStart:
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
    lda #0
    sta curPosX
    lda #5
    sta curPosY

!prompt:
    jsr resetInpBuf
    lda #asciiGreaterThan                   // prompt
    jsr printChar
    jsr incrCursor
    lda #asciiCursor                        // unused ASCII code is now Cursor
    jsr printChar
    lda #asciiSpace         
    sta cursorChar
!loop:
    // DEBUG START
/*     lda inpBufCur
    clc
    adc #$30                                // convert binary number to printable ASCII
    sta screenMemStart
    lda inpBufLen
    clc
    adc #$30                                // convert binary number to printable ASCII
    sta screenMemStart + 1 */
    // DEBUG END
    jsr getCharFromBuf
    cmp #$00
    beq !loop-
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
    beq !loop-

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
    jmp !loop-
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
    jmp !loop-
!enter:
    jsr processInpBuf
    jsr newLine
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

irqStart:                                   // triggered by hardware or software (BRK) interrupt
    pha                                     // store A
    txa
    pha                                     // store X
    tya
    pha                                     // store Y

    tsx                                     // store stack pointer to X
    lda $0104,x                             // $0100 = start of stack
                                            // X = stack pointer
                                            // +4 to get the status register
                                            // before that A,x and Y are stored
    and #%0001_0000                         // test break flag
    beq !notBrk+
    jmp (brkRoutineVector)
!notBrk:
    jmp (irqRoutineVector)

// ========================================

irqRoutine:
    jsr readKeyboard

    pla
    tay                                     // restore Y
    pla
    tax                                     // restore X
    pla                                     // restore A
    rti                                     // return to main program

// ========================================

brkRoutine:
    // do stuff
    pla
    tay                                     // restore Y
    pla
    tax                                     // restore X
    pla                                     // restore A
    rti                                     // return to main program

// ========================================

    *=fontStart "Font"

#import "lib/font.asm"

// ========================================

    *=softwareVectors "Software Vectors"

irqRoutineVector:
    .word irqRoutine
brkRoutineVector:
    .word brkRoutine

// ========================================

    *=hardwareVectors "Hardware Vectors"

    .word $0000                             // NMIB
    .word biosStart                         // RESB
    .word irqStart                          // IRQB

// ========================================
    