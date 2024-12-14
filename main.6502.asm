.target "6502"
.format "prg"
.setting "Debug", true
.setting "HandleLongBranch", true

// ========================================

HARDWARE_VECTORS    = $FFFA

NMIB                = $FFFA
RESB                = $FFFC
IRQB                = $FFFE

SOFTWARE_VECTORS    = $FFF6

PROGRAM_START       = $9000

// Constants
SCREEN_WIDTH        = 40            // 40 chars width * 8 = 320px
SCREEN_HEIGHT       = 30            // 30 chars height * 8 = 240px

// Zero Page variables
TMP_CURSOR          = $FE           // WORD $FE + $FF

// Screen related variables
CUR_POS_X           = $8000
CUR_POS_Y           = $8001

// Keyboard related variables
LAST_KEYPRESS       = $8002
CURRENT_KEYPRESS    = $8003

// ========================================

    *=PROGRAM_START

    //JSR TEST_SCREEN

    LDA #$81                        // unused ASCII code is now Cursor
    JSR PRINT_CHAR

PROGRAM_LOOP                        // main Bios loop
    JMP PROGRAM_LOOP

// ========================================

IRQ_START                           // triggered by hardware or software (BRK) interrupt
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
    BEQ @notBrk
    JMP (BRK_ROUTINE_VECTOR)
@notBrk
    JMP (IRQ_ROUTINE_VECTOR)

// ========================================

IRQ_ROUTINE
    JSR READ_KEYBOARD

    PLA
    TAY                             // restore Y
    PLA
    TAX                             // restore X
    PLA                             // restore A
    RTI                             // return to main program

// ========================================

BRK_ROUTINE
    // do stuff
    PLA
    TAY                             // restore Y
    PLA
    TAX                             // restore X
    PLA                             // restore A
    RTI                             // return to main program

// ========================================

shiftPressed .byte $00

READ_KEYBOARD                       // check all bits of $0200 - $0209 (hardware keyboard registers)
    LDA $0205                       // check if shift is pressed
    AND #%00000001
    BNE @shiftPressed
    LDA #0
    STA shiftPressed
    JMP @testKeys
@shiftPressed
    LDA #1
    STA shiftPressed
@testKeys
    LDA $0200                       // test all other keys
    AND #%00000001
    BNE @KeyA
    LDA $0200
    AND #%00000010
    BNE @KeyB
    LDA $0200
    AND #%00000100
    BNE @KeyC
    LDA $0200
    AND #%00001000
    BNE @KeyD
    LDA $0200
    AND #%00010000
    BNE @KeyE
    LDA $0200
    AND #%00100000
    BNE @KeyF
    LDA $0200
    AND #%01000000
    BNE @KeyG
    LDA $0200
    AND #%10000000
    BNE @KeyH
    LDA $0201
    AND #%00000001
    BNE @KeyI
    LDA $0201
    AND #%00000010
    BNE @KeyJ
    LDA $0201
    AND #%00000100
    BNE @KeyK
    LDA $0201
    AND #%00001000
    BNE @KeyL
    LDA $0201
    AND #%00010000
    BNE @KeyM
    LDA $0201
    AND #%00100000
    BNE @KeyN
    LDA $0201
    AND #%01000000
    BNE @KeyO
    LDA $0201
    AND #%10000000
    BNE @KeyP
    LDA $0202
    AND #%00000001
    BNE @KeyQ
    LDA $0202
    AND #%00000010
    BNE @KeyR
    LDA $0202
    AND #%00000100
    BNE @KeyS
    LDA $0202
    AND #%00001000
    BNE @KeyT
    LDA $0202
    AND #%00010000
    BNE @KeyU
    LDA $0202
    AND #%00100000
    BNE @KeyV
    LDA $0202
    AND #%01000000
    BNE @KeyW
    LDA $0202
    AND #%10000000
    BNE @KeyX
    LDA $0203
    AND #%00000001
    BNE @KeyY
    LDA $0203
    AND #%00000010
    BNE @KeyZ
    LDA $0203
    AND #%00000100
    BNE @Digit1
    LDA $0203
    AND #%00001000
    BNE @Digit2
    LDA $0203
    AND #%00010000
    BNE @Digit3
    LDA $0203
    AND #%00100000
    BNE @Digit4
    LDA $0203
    AND #%01000000
    BNE @Digit5
    LDA $0203
    AND #%10000000
    BNE @Digit6
    LDA $0204
    AND #%00000001
    BNE @Digit7
    LDA $0204
    AND #%00000010
    BNE @Digit8
    LDA $0204
    AND #%00000100
    BNE @Digit9
    LDA $0204
    AND #%00001000
    BNE @Digit0
    LDA $0204
    AND #%00010000
    BNE @Minus
    LDA $0204
    AND #%00100000
    BNE @Equal
    LDA $0204
    AND #%01000000
    BNE @Comma
    LDA $0204
    AND #%10000000
    BNE @Period
/*     LDA $0205
    AND #%00000001
    BNE @Shift */
    LDA $0205
    AND #%00000010
    BNE @Control
    LDA $0205
    AND #%00000100
    BNE @Alt
    LDA $0205
    AND #%00001000
    BNE @Meta
    LDA $0205
    AND #%00010000
    BNE @Tab
    LDA $0205
    AND #%00100000
    BNE @CapsLock
    LDA $0205
    AND #%01000000
    BNE @Space
    LDA $0205
    AND #%10000000
    BNE @Slash
    LDA $0206
    AND #%00000001
    BNE @ArrowLeft
    LDA $0206
    AND #%00000010
    BNE @ArrowRight
    LDA $0206
    AND #%00000100
    BNE @ArrowUp
    LDA $0206
    AND #%00001000
    BNE @ArrowDown
    LDA $0206
    AND #%00010000
    BNE @Enter
    LDA $0206
    AND #%00100000
    BNE @Backspace
    LDA $0206
    AND #%01000000
    BNE @Escape
    LDA $0206
    AND #%10000000
    BNE @Backslash
    LDA $0207
    AND #%00000001
    BNE @F1
    LDA $0207
    AND #%00000010
    BNE @F2
    LDA $0207
    AND #%00000100
    BNE @F3
    LDA $0207
    AND #%00001000
    BNE @F4
    LDA $0207
    AND #%00010000
    BNE @F5
    LDA $0207
    AND #%00100000
    BNE @F6
    LDA $0207
    AND #%01000000
    BNE @F7
    LDA $0207
    AND #%10000000
    BNE @F8
    LDA $0208
    AND #%00000001
    BNE @F9
    LDA $0208
    AND #%00000010
    BNE @F10
    LDA $0208
    AND #%00000100
    BNE @Semicolon
    LDA $0208
    AND #%00001000
    BNE @Quote
    LDA $0208
    AND #%00010000
    BNE @BracketLeft
    LDA $0208
    AND #%00100000
    BNE @BracketRight
    LDA $0208
    AND #%01000000
    BNE @Backquote
    LDA $0208
    AND #%10000000
    BNE @IntlBackslash
    LDA $0209
    AND #%00000001
    BNE @PageUp
    LDA $0209
    AND #%00000010
    BNE @PageDown
    LDA $0209
    AND #%00000100
    BNE @Home
    LDA $0209
    AND #%00001000
    BNE @End
    LDA $0209
    AND #%00010000
    BNE @Insert
    LDA $0209
    AND #%00100000
    BNE @Delete
    LDA $0209
    AND #%01000000
    BNE @PrintScreen
    LDA $0209
    AND #%10000000
    BNE @XXX
    JMP @NoKeypress
@KeyA
    LDA #$41
    JMP @continue
@KeyB
    LDA #$42
    JMP @continue
@KeyC
    LDA #$43
    JMP @continue
@KeyD
    LDA #$44
    JMP @continue
@KeyE
    LDA #$45
    JMP @continue
@KeyF
    LDA #$46
    JMP @continue
@KeyG
    LDA #$47
    JMP @continue
@KeyH
    LDA #$48
    JMP @continue
@KeyI
    LDA #$49
    JMP @continue
@KeyJ
    LDA #$4A
    JMP @continue
@KeyK
    LDA #$4B
    JMP @continue
@KeyL
    LDA #$4C
    JMP @continue
@KeyM
    LDA #$4D
    JMP @continue
@KeyN
    LDA #$4E
    JMP @continue
@KeyO
    LDA #$4F
    JMP @continue
@KeyP
    LDA #$50
    JMP @continue
@KeyQ
    LDA #$51
    JMP @continue
@KeyR
    LDA #$52
    JMP @continue
@KeyS
    LDA #$53
    JMP @continue
@KeyT
    LDA #$54
    JMP @continue
@KeyU
    LDA #$55
    JMP @continue
@KeyV
    LDA #$56
    JMP @continue
@KeyW
    LDA #$57
    JMP @continue
@KeyX
    LDA #$58
    JMP @continue
@KeyY
    LDA #$59
    JMP @continue
@KeyZ
    LDA #$5A
    JMP @continue
@Digit1
    LDA #$31
    JMP @continue
@Digit2
    LDA #$32
    JMP @continue
@Digit3
    LDA #$33
    JMP @continue
@Digit4
    LDA #$34
    JMP @continue
@Digit5
    LDA #$35
    JMP @continue
@Digit6
    LDA #$36
    JMP @continue
@Digit7
    LDA #$37
    JMP @continue
@Digit8
    LDA #$38
    JMP @continue
@Digit9
    LDA #$39
    JMP @continue
@Digit0
    LDA #$30
    JMP @continue
@Minus
    LDA #$2D
    JMP @continue
@Equal
    LDA #$3D
    JMP @continue
@Comma
    LDA #$2C
    JMP @continue
@Period
    LDA #$2E
    JMP @continue
/* @Shift
    LDA #$20
    JMP @continue */
@Control
    LDA #$00
    JMP @continue
@Alt
    LDA #$00
    JMP @continue
@Meta
    LDA #$00
    JMP @continue
@Tab
    LDA #$00
    JMP @continue
@CapsLock
    LDA #$00
    JMP @continue
@Space
    LDA #$20
    JMP @continue
@Slash
    LDA #$2F
    JMP @continue
@ArrowLeft
    LDA #$00
    JMP @continue
@ArrowRight
    LDA #$00
    JMP @continue
@ArrowUp
    LDA #$00
    JMP @continue
@ArrowDown
    LDA #$00
    JMP @continue
@Enter
    LDA #$0A                            // line feed
    JMP @continueEnter
@Backspace
    LDA #$20
    JMP @continueBackspace
@Escape
    LDA #$00
    JMP @continue
@Backslash
    LDA #$5C
    JMP @continue
@F1
    LDA #$00
    JMP @continue
@F2
    LDA #$00
    JMP @continue
@F3
    LDA #$00
    JMP @continue
@F4
    LDA #$00
    JMP @continue
@F5
    LDA #$00
    JMP @continue
@F6
    LDA #$00
    JMP @continue
@F7
    LDA #$00
    JMP @continue
@F8
    LDA #$00
    JMP @continue
@F9
    LDA #$00
    JMP @continue
@F10
    LDA #$00
    JMP @continue
@Semicolon
    LDA #$3B
    JMP @continue
@Quote
    LDA #$27
    JMP @continue
@BracketLeft
    LDA #$5B
    JMP @continue
@BracketRight
    LDA #$5D
    JMP @continue
@Backquote
    LDA #$60
    JMP @continue
@IntlBackslash
    LDA #$00
    JMP @continue
@PageUp
    LDA #$00
    JMP @continue
@PageDown
    LDA #$00
    JMP @continue
@Home
    LDA #$00
    JMP @continue
@End
    LDA #$00
    JMP @continue
@Insert
    LDA #$00
    JMP @continue
@Delete
    LDA #$00
    JMP @continue
@PrintScreen
    LDA #$00
    JMP @continue
@XXX
    LDA #$00
    JMP @continue

@NoKeypress
    LDA $00
    STA CURRENT_KEYPRESS
    STA LAST_KEYPRESS
    JMP @return

@continueEnter
    STA CURRENT_KEYPRESS                        // a contains keypress
    CMP LAST_KEYPRESS                           // if previous key is still pressed do nothing
    BEQ @return
    STA LAST_KEYPRESS                           // store current keypress in last keypress
    LDA #$20                                    // ASCII blank space
    JSR PRINT_CHAR                              // override current pos with blank to clear cursor
    LDA #0                                      // set cursor to next line
    STA CUR_POS_X                               // by setting x to 0
    INC CUR_POS_Y                               // and increasing y until
    LDA CUR_POS_Y                               // height reached
    CMP #SCREEN_HEIGHT                          // then return to first line
    BNE @printCursor
    LDA #0
    STA CUR_POS_Y
    JMP @printCursor

@continueBackspace
    STA CURRENT_KEYPRESS                        // a contains keypress
    CMP LAST_KEYPRESS                           // if previous key is still pressed do nothing
    BEQ @return
    STA LAST_KEYPRESS                           // store current keypress in last keypress
    JSR PRINT_CHAR                              // override current pos with blank to clear cursor
    JSR DECREMENT_POINTER
    JSR PRINT_CHAR                              // print keypress to screen
    LDA CURRENT_KEYPRESS
    JMP @printCursor

@continue
    CMP #$41                                    // check if key is a shiftable character 
    BCC @upperCase                              // if >=$41 and <=$5A
    CMP #$5A                                    // not if <$41 or >$5A
    BEQ @lowerCase
    BCS @upperCase
@lowerCase
    LDX shiftPressed                            // if shift is pressed add $20 to key which
    CPX #0                                      // effectively turns uppercase into lowercase
    BNE @upperCase
    CLC
    ADC #$20
@upperCase
    STA CURRENT_KEYPRESS                        // a contains keypress
    CMP LAST_KEYPRESS                           // if previous key is still pressed do nothing
    BEQ @return
    STA LAST_KEYPRESS                           // store current keypress in last keypress
    JSR PRINT_CHAR                              // print keypress to screen
    JSR INCREMENT_POINTER

@printCursor
    LDA #$81                                    // unused ASCII code is now Cursor
    JSR PRINT_CHAR

@return
    RTS

// ========================================

testScreenTmp .byte $00
testScreenMin .byte $20
testScreenMax .byte $7E

TEST_SCREEN                                     // fill screen with all printable chars
    LDA testScreenMin
    STA testScreenTmp
@loop                               
    JSR PRINT_CHAR
    INC testScreenTmp
    LDA testScreenTmp
    CMP testScreenMax
    BEQ @loop
    BCS TEST_SCREEN
    JMP @loop
@return
    RTS

// ========================================

PRINT_CHAR                                      // print char stored in A to screen and increment cursor
    PHA                                         // store A to stack
    LDA #<$0400                                 // calculate current cur pos
    STA TMP_CURSOR
    LDA #>$0400
    STA TMP_CURSOR + 1

    LDY CUR_POS_Y
@addY                                           // loop through all rows and
    CPY #0                                      // at the end add current x
    BEQ @addX                                   // to get current cursor
    LDA TMP_CURSOR
    CLC
    ADC #SCREEN_WIDTH                           // add screen width to cursor
    STA TMP_CURSOR
    LDA TMP_CURSOR + 1
    ADC #0
    STA TMP_CURSOR + 1
    DEY 
    JMP @addY
@addX
    LDA TMP_CURSOR
    CLC
    ADC CUR_POS_X                               // add x to cursor
    STA TMP_CURSOR
    LDA TMP_CURSOR + 1
    ADC #0
    STA TMP_CURSOR + 1
@printChar
    PLA                                         // get current char stored in A
    LDX #0
    STA (TMP_CURSOR,X)                          // print char to screen
@return
    RTS

// ========================================

INCREMENT_POINTER
@incX
    INC CUR_POS_X                               // set cur pos to next pos
    LDX CUR_POS_X
    CPX #SCREEN_WIDTH                           // screen width reached?
    BEQ @incY
    JMP @return
@incY
    LDX #0
    STX CUR_POS_X                               // set pos x to 0
    INC CUR_POS_Y                               // increment pos y
    LDY CUR_POS_Y
    CPY #SCREEN_HEIGHT                          // screen height reached?
    BEQ @reset
    JMP @return
@reset
    LDY #0
    STY CUR_POS_Y                               // set pos y to 0
@return
    RTS

// ========================================

DECREMENT_POINTER
@decX
    DEC CUR_POS_X                               // set cur pos to previous pos
    LDX CUR_POS_X
    CPX #255                                    // left screen border reached?
    BEQ @decY
    JMP @return
@decY
    LDX #SCREEN_WIDTH - 1
    STX CUR_POS_X                               // set pos x to screen width
    DEC CUR_POS_Y                               // decrement pos y
    LDY CUR_POS_Y
    CPY #255                                    // upper screen border reached?
    BEQ @reset
    JMP @return
@reset
    LDY #SCREEN_HEIGHT - 1
    STY CUR_POS_Y                               // set pos y to screen height
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
    .word IRQ_START                 // IRQB
    