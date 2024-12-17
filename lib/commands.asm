// ========================================

paramLength: .byte $00

echoCommand:
    lda inpBufLen                       // INP_BUF_LEN - 6 = length of parameter to print
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
    beq !return+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!return:
    ldx #<terminalOutputBuffer
    ldy #>terminalOutputBuffer
    jsr printTerminalLine
    rts

// ========================================