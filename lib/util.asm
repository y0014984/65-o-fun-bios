// ========================================

#importonce 

#import "terminal.asm"

// ========================================

// Increments a WORD address stored in zero page
// A: start of the address in zero page

// Preserves: A, X, Y

paramIncrZpAddr: .byte $00

.label lowByteZp = $00
.label highByteZp = $01

incrZeropageAddr:
    sta paramIncrZpAddr
    pha
    txa
    pha
    tya
    pha
!incrementLowByte:
    ldx paramIncrZpAddr
    inc lowByteZp,x
    lda #lowByteZp
    cmp lowByteZp,x
    bne !return+
!incrementHighByte:
    inc highByteZp,x
!return:
    pla
    tay
    pla
    tax
    pla
    rts

// ========================================

// Decrements a WORD address stored in zero page
// A: start of the address in zero page

// Preserves: A, X, Y

paramDecrZpAddr: .byte $00

decrZeropageAddr:
    sta paramDecrZpAddr
    pha
    txa
    pha
    tya
    pha
!incrementLowByte:
    ldx paramDecrZpAddr
    dec $00,x
    lda #$00
    cmp $00,x
    bne !return+
!incrementHighByte:
    dec $01,x
!return:
    pla
    tay
    pla
    tax
    pla
    rts

// ========================================

acc: .word 0
aux: .word 10 // constant
ext: .word 0

// ========================================

// print a 8-bit integer with only 2 digits
// Parameter: A

print8:
    sta acc
    ldx #0
    stx acc+1

    lda #$20
    sta num8Digits+0
    sta num8Digits+1
    sta num8Digits+2

    ldx #2
!nextDigit:
    jsr divide
    lda ext
    sta num8,x
    dex
    bpl !nextDigit-

!firstDigit:
    inx
    cpx #3
    beq !printZero+
    lda num8,x
    beq !firstDigit-

!printNextDigit:
    clc
    adc #'0'
    sta num8Digits,x
    inx
    cpx #3
    beq !return+
    lda num8,x
    jmp !printNextDigit-

!return:
    rts

!printZero:
    lda #'0'
    sta num8Digits-1,x
    rts

num8: .byte $00, $00, $00
num8Digits: .byte $20, $20, $20

// ========================================

// print a 16-bit integer
// Parameter: LSB in X, MSB in A

print16:
    stx acc
    sta acc+1

    lda #$20
    sta num16Digits+0
    sta num16Digits+1
    sta num16Digits+2
    sta num16Digits+3
    sta num16Digits+4

    ldx #4
!nextDigit:
    jsr divide
    lda ext
    sta num16,x
    dex
    bpl !nextDigit-

!firstDigit:
    inx
    cpx #5
    beq !printZero+
    lda num16,x
    beq !firstDigit-

!printNextDigit:
    clc
    adc #'0'
    sta num16Digits,x
    inx
    cpx #5
    beq !return+
    lda num16,x
    jmp !printNextDigit-

!return:
    rts

!printZero:
    lda #'0'
    sta num16Digits-1,x
    rts

num16: .byte $00, $00, $00, $00, $00
num16Digits: .byte $00, $00, $00, $00, $00

// ========================================

// 16/16-bit division, from the fridge
// acc/aux -> acc, remainder in ext

divide:
    lda #0
    sta ext+1
    ldy #$10
!loop:
    asl acc
    rol acc+1
    rol
    rol ext+1
    pha
    cmp aux
    lda ext+1
    sbc aux+1
    bcc !continue+
    sta ext+1
    pla
    sbc aux
    pha
    inc acc
!continue:
    pla
    dey
    bne !loop-
    sta ext
    rts

// ========================================