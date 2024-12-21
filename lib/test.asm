// ========================================

#importonce 

#import "../labels.asm"
#import "terminal.asm"

// ========================================

.const testScreenMin   = $20
.const testScreenMax   = $7E

// ========================================

testScreenTmp: .byte $00

testScreen:                             // fill screen with all printable chars
    lda #testScreenMin
    sta testScreenTmp
!loop:
    jsr printChar
    jsr incrCursor

    lsr foregroundColor                 // increment foreground color
    lsr foregroundColor
    inc foregroundColor
    asl foregroundColor
    asl foregroundColor
    lda foregroundColor
    ora #%00000011
    sta foregroundColor

    inc testScreenTmp
    lda testScreenTmp
    cmp #testScreenMax
    beq !loop-
    bcs testScreen
    jmp !loop-
!return:
    rts

// ========================================