// ========================================

.label PROGRAM_START       = $8000

.label hardwareVectors     = $FFFA

.label softwareVectors     = $FFF6

.label NMIB                = $FFFA
.label RESB                = $FFFC
.label IRQB                = $FFFE

// ========================================

/* 
        Verify decimal mode behavior
        Written by Bruce Clark.  This code is public domain.

        Returns:
        ERROR = 0 if the test passed
        ERROR = 1 if the test failed

        This routine requires 17 bytes of RAM -- 1 byte each for:
        AR, CF, DA, DNVZC, ERROR, HA, HNVZC, N1, N1H, N1L, N2, N2L, NF, VF, and ZF
        and 2 bytes for N2H

        Variables:
        N1 and N2 are the two numbers to be added or subtracted
        N1H, N1L, N2H, and N2L are the upper 4 bits and lower 4 bits of N1 and N2
        DA and DNVZC are the actual accumulator and flag results in decimal mode
        HA and HNVZC are the accumulator and flag results when N1 and N2 are
        added or subtracted using binary arithmetic
        AR, NF, VF, ZF, and CF are the predicted decimal mode accumulator and
        flag results, calculated using binary arithmetic

        This program takes approximately 1 minute at 1 MHz (a few seconds more on
        a 65C02 than a 6502 or 65816)
*/

        *=PROGRAM_START

        jmp FUNCTION_CALL

TEST:   ldy #1    // initialize Y (used to loop through carry flag values)
        sty ERROR // store 1 in ERROR until the test passes
        lda #0    // initialize N1 and N2
        sta N1
        sta N2
LOOP1:  lda N2    // N2L = N2 & $0F
        and #$0F  // [1] see text
        sta N2L
        lda N2    // N2H = N2 & $F0
        and #$F0  // [2] see text
        sta N2H
        ora #$0F  // N2H+1 = (N2 & $F0) + $0F
        sta N2H+1
LOOP2:  lda N1    // N1L = N1 & $0F
        and #$0F  // [3] see text
        sta N1L
        lda N1    // N1H = N1 & $F0
        and #$F0  // [4] see text
        sta N1H
        jsr ADD
        jsr A6502
        jsr COMPARE
        bne DONE
        jsr SUB
        jsr S6502
        jsr COMPARE
        bne DONE
        inc N1    // [5] see text
        bne LOOP2 // loop through all 256 values of N1
        inc N2    // [6] see text
        bne LOOP1 // loop through all 256 values of N2
        dey
        bpl LOOP1 // loop through both values of the carry flag
        lda #0    // test passed, so store 0 in ERROR
        sta ERROR
DONE:   rts

/*
        Calculate the actual decimal mode accumulator and flags, the accumulator
        and flag results when N1 is added to N2 using binary arithmetic, the
        predicted accumulator result, the predicted carry flag, and the predicted
        V flag
*/

ADD:    sed       // decimal mode
        cpy #1    // set carry if Y = 1, clear carry if Y = 0
        lda N1
        adc N2
        sta DA    // actual accumulator result in decimal mode
        php
        pla
        sta DNVZC // actual flags result in decimal mode
        cld       // binary mode
        cpy #1    // set carry if Y = 1, clear carry if Y = 0
        lda N1
        adc N2
        sta HA    // accumulator result of N1+N2 using binary arithmetic

        php
        pla
        sta HNVZC // flags result of N1+N2 using binary arithmetic
        cpy #1
        lda N1L
        adc N2L
        cmp #$0A
        ldx #0
        bcc A1
        inx
        adc #5    // add 6 (carry is set)
        and #$0F
        sec
A1:     ora N1H

/*
        if N1L + N2L <  $0A, then add N2 & $F0
        if N1L + N2L >= $0A, then add (N2 & $F0) + $0F + 1 (carry is set)
*/

        adc N2H,x
        php
        bcs A2
        cmp #$A0
        bcc A3
A2:     adc #$5F  // add $60 (carry is set)
        sec
A3:     sta AR    // predicted accumulator result
        php
        pla
        sta CF    // predicted carry result
        pla

/*
        note that all 8 bits of the P register are stored in VF
*/

        sta VF    // predicted V flags
        rts

/* 
        Calculate the actual decimal mode accumulator and flags, and the
        accumulator and flag results when N2 is subtracted from N1 using binary
        arithmetic
*/

SUB:    sed       // decimal mode
        cpy #1    // set carry if Y = 1, clear carry if Y = 0
        lda N1
        sbc N2
        sta DA    // actual accumulator result in decimal mode
        php
        pla
        sta DNVZC // actual flags result in decimal mode
        cld       // binary mode
        cpy #1    // set carry if Y = 1, clear carry if Y = 0
        lda N1
        sbc N2
        sta HA    // accumulator result of N1-N2 using binary arithmetic

        php
        pla
        sta HNVZC // flags result of N1-N2 using binary arithmetic
        rts

// Calculate the predicted sbc accumulator result for the 6502 and 65816


SUB1:   cpy #1    // set carry if Y = 1, clear carry if Y = 0
        lda N1L
        sbc N2L
        ldx #0
        bcs S11
        inx
        sbc #5    // subtract 6 (carry is clear)
        and #$0F
        clc
S11:    ora N1H

/*
        if N1L - N2L >= 0, then subtract N2 & $F0
        if N1L - N2L <  0, then subtract (N2 & $F0) + $0F + 1 (carry is clear)
*/

        sbc N2H,x
        bcs S12
        sbc #$5F  // subtract $60 (carry is clear)
S12:    sta AR
        rts

// Calculate the predicted sbc accumulator result for the 6502 and 65C02

SUB2:   cpy #1    // set carry if Y = 1, clear carry if Y = 0
        lda N1L
        sbc N2L
        ldx #0
        bcs S21
        inx
        and #$0F
        clc
S21:    ora N1H

/*
        if N1L - N2L >= 0, then subtract N2 & $F0
        if N1L - N2L <  0, then subtract (N2 & $F0) + $0F + 1 (carry is clear)
*/

        sbc N2H,x
        bcs S22
        sbc #$5F   // subtract $60 (carry is clear)
S22:    cpx #0
        beq S23
        sbc #6
S23:    sta AR     // predicted accumulator result
        rts

/* 
        Compare accumulator actual results to predicted results
        Return:
          Z flag = 1 (beq branch) if same
          Z flag = 0 (bne branch) if different
*/

COMPARE:lda DA
        cmp AR
        bne C1
/*         lda DNVZC // [7] see text
        eor NF
        and #$80  // mask off N flag
        bne C1
        lda DNVZC // [8] see text
        eor VF
        and #$40  // mask off V flag
        bne C1    // [9] see text
        lda DNVZC
        eor ZF    // mask off Z flag
        and #2
        bne C1    // [10] see text */
        lda DNVZC
        eor CF
        and #1    // mask off C flag
C1:     rts

/*
        These routines store the predicted values for adc and sbc for the 6502,
        65C02, and 65816 in AR, CF, NF, VF, and ZF 
*/

A6502:  lda VF

/*
        since all 8 bits of the P register were stored in VF, bit 7 of VF contains
        the N flag for NF
*/

        sta NF
        lda HNVZC
        sta ZF
        rts

S6502:  jsr SUB1
        lda HNVZC
        sta NF
        sta VF
        sta ZF
        sta CF
        rts

A65C02: lda AR
        php
        pla
        sta NF
        sta ZF
        rts

S65C02: jsr SUB2
        lda AR
        php
        pla
        sta NF
        sta ZF
        lda HNVZC
        sta VF
        sta CF
        rts

A65816: lda AR
        php
        pla
        sta NF
        sta ZF
        rts

S65816: jsr SUB1
        lda AR
        php
        pla
        sta NF
        sta ZF
        lda HNVZC
        sta VF
        sta CF
        rts

// variables

AR:      .byte $00
CF:      .byte $00
DA:      .byte $00
DNVZC:   .byte $00
ERROR:   .byte $00
HA:      .byte $00
HNVZC:   .byte $00
N1:      .byte $00
N1H:     .byte $00
N1L:     .byte $00
N2:      .byte $00
N2L:     .byte $00
NF:      .byte $00
VF:      .byte $00
ZF:      .byte $00
N2H:     .word $0000

FUNCTION_CALL:
        jsr TEST
        lda ERROR
        clc
        adc #$30
        sta $0400

// ========================================

irqStart:                           // triggered by hardware or software (BRK) interrupt
    pha                             // store A
    txa
    pha                             // store X
    tya
    pha                             // store Y

    tsx                             // store stack pointer to X
    lda $0104,x                     // $0100 = start of stack
                                    // X = stack pointer
                                    // +4 to get the status register
                                    // before that A,x and Y are stored
    and #%0001_0000                 // test break flag
    beq !notBrk+
    jmp (brkRoutineVector)
!notBrk:
    jmp (irqRoutineVector)

// ========================================

irqRoutine:

    pla
    tay                             // restore Y
    pla
    tax                             // restore X
    pla                             // restore A
    rti                             // return to main program

// ========================================

brkRoutine:
    // do stuff
    pla
    tay                             // restore Y
    pla
    tax                             // restore X
    pla                             // restore A
    rti                             // return to main program

// ========================================

    *=softwareVectors

irqRoutineVector:
    .word irqRoutine
brkRoutineVector:
    .word brkRoutine

// ========================================

    *=hardwareVectors

    .word $0000                     // NMIB
    .word $0000                     // RESB
    .word irqStart                  // IRQB

// ========================================