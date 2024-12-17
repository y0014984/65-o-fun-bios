// ========================================

// Increments a WORD address stored in zero page
// A: start of the address in zero page

// Preserves: A, X, Y

paramIncrZpAddr: .byte $00

incrZeropageAddr:
    sta paramIncrZpAddr
    pha
    txa
    pha
    tya
    pha
!incrementLowByte:
    ldx paramIncrZpAddr
    inc $00,X
    lda #$00
    cmp $00,X
    bne !return+
!incrementHighByte:
    inc $01,X
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
    dec $00,X
    lda #$00
    cmp $00,X
    bne !return+
!incrementHighByte:
    dec $01,X
!return:
    pla
    tay
    pla
    tax
    pla
    rts

// ========================================