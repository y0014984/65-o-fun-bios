// Kick Assembler v5.25

// ========================================

#define DEBUG

.encoding "ascii"

// ========================================

#import "labels.asm"
#import "constants.asm"

// ========================================

.segmentdef ZeroPage [start=$00, virtual]
.segmentdef Stack [start=$0100, virtual]
.segmentdef Registers [start=$0200, virtual]
.segmentdef Buffers [start=$0300, virtual]
.segmentdef ScreenMem [start=screenMemStart, virtual]
.segmentdef BIOS [start=biosStart, outPrg="bios.prg"]

// ========================================

.segment ZeroPage

.fill 256, $00

// ========================================

.segment Stack

.fill 256, $00

// ========================================

.segment Registers

.fill 256, $00

// ========================================

.segment Buffers

.fill 256, $00

// ========================================

.segment ScreenMem

.fill screenWidth*screenHeight, $00

// ========================================

.segment BIOS

.memblock "Kernal"

    jsr initStorage

// ========================================

    #if !DEBUG

    //jsr testScreen
    //jsr testFontWrite
    //jsr testStorage
    jsr testColorMode

    #endif

// ========================================

    jmp terminalStart

// ========================================

#import "lib/commands.asm"
#import "lib/keyboard.asm"
#import "lib/terminal.asm"
#import "lib/storage.asm"
#import "lib/util.asm"
#import "lib/editor.asm"
#importif !DEBUG "lib/test.asm"

// ========================================

irqStart:                                   // triggered by hardware or software (BRK) interrupt
    pha                                     // store A
    txa
    pha                                     // store X
    tya
    pha                                     // store Y

    tsx                                     // store stack pointer to X
    lda $0104,x                             // $0100 = start of stack
                                            // X = stack pointer
                                            // +4 to get the status register
                                            // before that A,x and Y are stored
    and #%0001_0000                         // test break flag
    beq !notBrk+
    jmp (brkRoutineVector)
!notBrk:
    jmp (irqRoutineVector)

// ========================================

irqRoutine:
    jsr readKeyboard

    pla
    tay                                     // restore Y
    pla
    tax                                     // restore X
    pla                                     // restore A
    rti                                     // return to main program

// ========================================

brkRoutine:
    // do stuff
    pla
    tay                                     // restore Y
    pla
    tax                                     // restore X
    pla                                     // restore A
    rti                                     // return to main program

// ========================================

    *=fontStart "Font"

#import "fonts/Default.asm"

// ========================================

    *=softwareVectors "Software Vectors"

irqRoutineVector:
    .word irqRoutine
brkRoutineVector:
    .word brkRoutine

// ========================================

    *=hardwareVectors "Hardware Vectors"

    .word $0000                             // NMIB
    .word biosStart                         // RESB
    .word irqStart                          // IRQB

// ========================================