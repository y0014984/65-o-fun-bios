// ========================================

#importonce 

#import "../labels.asm"
#import "terminal.asm"

#import "storage.asm"

// ========================================

.const testScreenMin   = $20
.const testScreenMax   = $7E

// ========================================

testScreenTmp: .byte $00

testScreen:                                 // fill screen with all printable chars
    lda #testScreenMin
    sta testScreenTmp
!loop:
    jsr printChar
    jsr incrCursor

    lsr foregroundColor                     // increment foreground color
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

testFontWrite:
    lda #%01010101
    sta $d000+32
    lda #%10101010
    sta $d001+32
    lda #%01010101
    sta $d002+32
    lda #%10101010
    sta $d003+32
    lda #%01010101
    sta $d004+32
    lda #%10101010
    sta $d005+32
    lda #%01010101
    sta $d006+32
    lda #%10101010
    sta $d007+32

    lda #$23
    sta $0400
    lda #$00+4
    sta $0401
    lda #$23
    sta $0402
!loop:
    jmp !loop-
!return:
    rts

// ========================================

testStorage:
!getFilesystemObjectCount:
    lda #'F'
    sta commandBuffer
    lda #'O'
    sta commandBuffer+1
    lda #'C'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

!waitForResult:
    lda storageComFlow
    cmp #commandFlowDone
    bne !waitForResult-
    lda storageComRetVal

!getFilesystemObjectType:
    lda #'G'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'T'
    sta commandBuffer+2
    lda #2
    sta commandBuffer+3

    lda #commandFlowReady
    sta storageComFlow

!waitForResult:
    lda storageComFlow
    cmp #commandFlowDone
    bne !waitForResult-
    lda storageComRetVal
    ldx readWriteBuffer

    brk
    nop

!loop:
    jmp !loop-

!return:
    rts

// ========================================