.target "6502"
.format "prg"
.setting "Debug", true

// ========================================

HARDWARE_VECTORS    = $FFFA

NMIB                = $FFFA
RESB                = $FFFC
IRQB                = $FFFE

SOFTWARE_VECTORS    = $FFF6

PROGRAM_START       = $8000

CUR_POS_X           = $9000
CUR_POS_Y           = $9001

// ========================================

    *=PROGRAM_START

PROGRAM_LOOP
    INC $0300
    JMP PROGRAM_LOOP

IRQ
    PHA                             // store A
    TXA
    PHA                             // store X
    TYA
    PHA                             // store Y

    TSX                             // store stack pointer to X
    LDA $0104,X                     // $0100 = start of stack
                                    // X = stack pointer
                                    // +4 to get the status register
                                    // before that A,X and Y are stored
    AND #%0001_0000                 // test break flag
    BEQ NOT_BRK
    JMP (BRK_ROUTINE_VECTOR)

NOT_BRK
    JMP (IRQ_ROUTINE_VECTOR)

IRQ_ROUTINE
    // do stuff
    INC $0301
    JSR READ_KEYBOARD

    PLA
    TAY                             // restore Y
    PLA
    TAX                             // restore X
    PLA                             // restore A
    RTI                             // return to main program

BRK_ROUTINE
    // do stuff
    PLA
    TAY                             // restore Y
    PLA
    TAX                             // restore X
    PLA                             // restore A
    RTI                             // return to main program

READ_KEYBOARD
    LDA $0200
    AND #%00000001
    BNE @A
    LDA $0200
    AND #%00000010
    BNE @B
    JMP @return
@A
    LDA #$41
    JMP @continue
@B
    LDA #$42
    JMP @continue

@continue
    LDX CUR_POS_X
    STA $0400,X
    INC CUR_POS_X
    INC $0302

@return
    RTS

// ========================================

    *=SOFTWARE_VECTORS
IRQ_ROUTINE_VECTOR
    .word IRQ_ROUTINE
BRK_ROUTINE_VECTOR
    .word BRK_ROUTINE

// ========================================

    *=HARDWARE_VECTORS
    .word $0000                     // NMIB
    .word PROGRAM_START             // RESB
    .word IRQ                       // IRQB
    