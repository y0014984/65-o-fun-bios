// ========================================

#importonce 

#import "../constants.asm"
#import "terminal.asm"

// ========================================

paramLength: .byte $00

echoCommand:
    // DEBUG START
/*     lda inpBufLen
    clc 
    adc #$30
    sta $0403 */
    // DEBUG END

    lda inpBufLen                       // INP_BUF_LEN - 6 = length of parameter to print
    cmp #6
    bcc !return+                        // A<6 = no parameter
    sec
    sbc #5
    sta paramLength

    ldx #6                              // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda tmpCursor
    sta sourceAddr
    lda tmpCursor + 1
    sta sourceAddr + 1
                    
    lda #<terminalOutputBuffer          // copy start of terminal output buffer to destination address
    sta destinationAddr
    lda #>terminalOutputBuffer
    sta destinationAddr + 1

    ldy #0                              // copy parameter to next line until a $00 is reached
!loop:
    cpy paramLength
    beq !print+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!print:
    ldx #<terminalOutputBuffer
    ldy #>terminalOutputBuffer
    jsr printTerminalLine

!return:
    rts

// ========================================

clearCommand:
    lda #asciiSpace
    jsr fillScreen
    lda #0
    sta curPosX
    lda #255
    sta curPosY
!return:
    rts

// ========================================

unameString: .text @"65-o-fun v0.1 BIOS\$00"

unameCommand:
    ldx #<unameString
    ldy #>unameString
    jsr printTerminalLine
!return:
    rts

// ========================================