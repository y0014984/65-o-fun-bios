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

dateString: .text @"Wee Mon DD HH:MM:SS CET YEAR\$00" // template
dayNames: .text "SunMonTueWedThuFriSat"
monthNames: .text "JanFebMarAprMayJunJulAugSepOctNovDec"
tmpIndex: .byte $00

dateCommand:
!getWeekday:
    lda dateTimeWeekdayMonth
    and #%11110000
    lsr
    lsr
    lsr
    lsr

!findWeekday:
    ldx #0
    stx tmpIndex
!loop:
    cmp tmpIndex
    beq !copyWeekday+
    inx
    inx
    inx
    inc tmpIndex
    jmp !loop-

!copyWeekday:
    ldy #0
!loop:
    lda dayNames,x
    sta dateString,y
    lda dayNames+1,x
    sta dateString+1,y
    lda dayNames+2,x
    sta dateString+2,y

!getMonth:
    lda dateTimeWeekdayMonth
    and #%00001111

!findMonth:
    ldx #0
    stx tmpIndex
!loop:
    cmp tmpIndex
    beq !copyMonth+
    inx
    inx
    inx
    inc tmpIndex
    jmp !loop-

!copyMonth:
    ldy #4
!loop:
    lda monthNames,x
    sta dateString,y
    lda monthNames+1,x
    sta dateString+1,y
    lda monthNames+2,x
    sta dateString+2,y

!getDay:
    lda dateTimeDay
    jsr print8

    ldx #8
!copyDay:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getHours:
    lda dateTimeHours
    jsr print8

    ldx #11
!copyHours:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getMinutes:
    lda dateTimeMinutes
    jsr print8

    ldx #14
!copyMinutes:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getSeconds:
    lda dateTimeSeconds
    jsr print8

    ldx #17
!copySeconds:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getYear:
    ldx dateTimeYear
    lda dateTimeYear+1
    jsr print16

    ldx #24
!copyYear:
    lda num16Digits+1
    sta dateString+0,x
    lda num16Digits+2
    sta dateString+1,x
    lda num16Digits+3
    sta dateString+2,x
    lda num16Digits+4
    sta dateString+3,x

!print:
    ldx #<dateString
    ldy #>dateString
    jsr printTerminalLine
!return:
    rts

// ========================================

// the output of this command could be precalculated
// with Kick Assembler scripting

helpString: .fill screenWidth, $00

helpCommand:
    ldx #0
    ldy #0
!loop:
    cpy #screenWidth - 1
    beq !print+
    lda commandList,x
    cmp #$00
    beq !addComma+
    sta helpString,y
    inx
    iny
    jmp !loop-

!addComma:
    lda commandList+1,x
    cmp #$00
    beq !printAndReturn+
    lda #asciiComma
    sta helpString,y
    inx
    iny
    jmp !loop-

!print:
    jsr printHelpString
    jsr clearHelpString
    ldy #0
    jmp !loop-

!printAndReturn:
    jsr printHelpString
    jsr clearHelpString

!return:
    rts

// --------------------

printHelpString:
    txa
    pha
    tya
    pha
    ldx #<helpString
    ldy #>helpString
    jsr printTerminalLine
!return:
    pla
    tay
    pla
    tax
    rts

// --------------------

clearHelpString:
    tya
    ldy #0
!loop:
    lda #$00
    sta helpString,y
    iny
    cpy #screenWidth
    beq !return+
    jmp !loop-
!return:
    tay
    rts

// ========================================