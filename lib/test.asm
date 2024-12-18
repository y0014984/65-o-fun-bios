// ========================================

#importonce 

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
    inc testScreenTmp
    lda testScreenTmp
    cmp #testScreenMax
    beq !loop-
    bcs testScreen
    jmp !loop-
!return:
    rts

// ========================================