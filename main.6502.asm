.target "6502"
.format "prg"
.setting "Debug", true
.setting "HandleLongBranch", true
.encoding "ascii", "mixed"

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
TMP_POINTER         = $FC           // WORD $FC + $FD = used by PRINT_STRING
TMP_CURSOR          = $FE           // WORD $FE + $FF = current pos in screen mem

// Screen related variables
CUR_POS_X           = $8000
CUR_POS_Y           = $8001
CURSOR_CHAR         = $8002

// Keyboard related variables
LAST_KEYPRESS       = $8003
CURRENT_KEYPRESS    = $8004

// BIOS related variables
INP_BUF_LEN     	= $8005
INP_BUF_CUR         = $8006

SOURCE_ADDR         = $F8           // WORD $F8 + $F9
DESTINATION_ADDR    = $FA           // WORD $FA + $FB 

// ========================================

    *=PROGRAM_START

    //JSR TEST_SCREEN

    JMP BIOS_START

// ========================================

welcomeMessageLine1 .textz "*** 65-o-fun v0.1 BIOS ***"
welcomeMessageLine2 .textz "created by y0014984 (c) 2024"


// ========================================

BIOS_START
    LDA #7                         // print welcome screen and prompt
    STA CUR_POS_X
    LDA #1
    STA CUR_POS_Y
    LDX #<welcomeMessageLine1
    LDY #>welcomeMessageLine1
    JSR PRINT_STRING
    LDA #6
    STA CUR_POS_X
    LDA #3
    STA CUR_POS_Y
    LDX #<welcomeMessageLine2
    LDY #>welcomeMessageLine2
    JSR PRINT_STRING
    LDA #0
    STA CUR_POS_X
    LDA #5
    STA CUR_POS_Y
@prompt
    LDA #$3E                        // GREATER THAN SIGN == prompt
    JSR PRINT_CHAR
    JSR INCREMENT_CURSOR
    LDA #$81                        // unused ASCII code is now Cursor
    JSR PRINT_CHAR
    LDA #$20                        // ASCII SPACE as the not set string under the cursor
    STA CURSOR_CHAR
@loop
    // DEBUG START
    LDA INP_BUF_CUR
    CLC
    ADC #$30                        // convert binary number to printable ASCII
    STA $0400
    LDA INP_BUF_LEN
    CLC
    ADC #$30                        // convert binary number to printable ASCII
    STA $0401
    // DEBUG END
    JSR GET_CHAR_FROM_BUFFER
    CMP #$00
    BEQ @loop
    CMP #$08                        // ASCII BACKSPACE
    BEQ @backspaceJump
    CMP #$0A                        // ASCII LINE FEED
    BEQ @enterJump
    CMP #$11                        // ASCII DEVICE CONTROL 1 = ARROW LEFT
    BEQ @arrowLeftJump
    CMP #$12                        // ASCII DEVICE CONTROL 2 = ARROW RIGHT
    BEQ @arrowRightJump
    JMP @jumpTableEnd
@backspaceJump
    JMP @backspace
@enterJump
    JMP @enter
@arrowLeftJump
    JMP @arrowLeft
@arrowRightJump
    JMP @arrowRight
@jumpTableEnd
    LDX CUR_POS_X                   // don't leave current input line
    CPX #SCREEN_WIDTH - 1
    BEQ @loop

    LDX INP_BUF_CUR                 // increment input buffer/cursor
    CPX INP_BUF_LEN
    BNE @noInpBufIncr
    INC INP_BUF_LEN
@noInpBufIncr
    INC INP_BUF_CUR

    JSR PRINT_CHAR
    JSR INCREMENT_CURSOR
    JSR GET_CHAR_ON_CUR_POS
    BNE @storeChar
    LDA #$20                        // use ASCII SPACE instead of $00/CURSOR to store
@storeChar
    STA CURSOR_CHAR
@printCursor
    LDA #$81                        // unused ASCII code is now Cursor
    JSR PRINT_CHAR
    JMP @loop
@backspace
    LDX CUR_POS_X                   // don't go beyond prompt
    CPX #1
    BEQ @loop

    LDX INP_BUF_CUR                 // decrement input buffer/cursor
    CPX INP_BUF_LEN
    BNE @noInpBufDecr
    DEC INP_BUF_LEN
@noInpBufDecr
    DEC INP_BUF_CUR

    LDA CURSOR_CHAR
    JSR PRINT_CHAR
    JSR DECREMENT_CURSOR
    LDA #$20                        // SPACE
    STA CURSOR_CHAR
    JSR PRINT_CHAR                  // override current pos with blank to clear cursor
    JMP @printCursor
@enter
    JSR PROCESS_INP_BUF
    LDA #0                          // new line
    STA CUR_POS_X
    INC CUR_POS_Y
    JMP @prompt
@arrowLeft
    LDX CUR_POS_X                   // don't go beyond prompt
    CPX #1
    BEQ @loop

    DEC INP_BUF_CUR                 // decrement input cursor

    LDA CURSOR_CHAR
    JSR PRINT_CHAR
    JSR DECREMENT_CURSOR
    JSR GET_CHAR_ON_CUR_POS
    STA CURSOR_CHAR
    JMP @printCursor
@arrowRight
    LDX INP_BUF_LEN                 // don't leave input buffer
    INX                             // + 1 for prompt
    CPX CUR_POS_X
    BEQ @loop

    LDX INP_BUF_CUR                 // increment input cursor
    CPX INP_BUF_LEN
    BEQ @noInpCurIncr
    INC INP_BUF_CUR
@noInpCurIncr

    LDA CURSOR_CHAR
    JSR PRINT_CHAR
    JSR INCREMENT_CURSOR
    JSR GET_CHAR_ON_CUR_POS
    CMP #$00                        // don't exceed beyond already printed chars
    BEQ @outsideInputString         // which is the end of the current input string
    STA CURSOR_CHAR
    JMP @printCursor
@outsideInputString
    JSR DECREMENT_CURSOR
    JMP @printCursor

// ========================================

commandNotFound .textz "Command not found"

echoCommand .textz "echo"

PROCESS_INP_BUF
    LDA #$20                        // overwrite cursor
    JSR PRINT_CHAR

    LDX #1                          // the current input buffer is in line CUR_POS_Y after
    LDY #0                          // the prompt and has the length INP_BUF_LEN
@loop
    LDA echoCommand,Y
    CMP #$00
    BEQ @echo
    STX CUR_POS_X
    JSR GET_CHAR_ON_CUR_POS
    CMP echoCommand,Y
    BNE @commandNotFound
    INX
    INY
    JMP @loop
@commandNotFound
    LDX #0                          // new line
    STX CUR_POS_X
    INC CUR_POS_Y
    LDX #<commandNotFound
    LDY #>commandNotFound
    JSR PRINT_STRING
    JMP @return
@echo
    JSR ECHO_COMMAND
@return
    RTS

// ========================================

ECHO_COMMAND
    LDX #6                          // copy start of parameter to source address
    STX CUR_POS_X
    JSR CALCULATE_CUR_POS
    LDA TMP_CURSOR
    STA SOURCE_ADDR
    LDA TMP_CURSOR + 1
    STA SOURCE_ADDR + 1

    LDX #0                          // copy start of next line to destination address
    STX CUR_POS_X
    INC CUR_POS_Y
    JSR CALCULATE_CUR_POS
    LDA TMP_CURSOR
    STA DESTINATION_ADDR
    LDA TMP_CURSOR + 1
    STA DESTINATION_ADDR + 1

    LDY #0                          // copy parameter to next line until a $00 is reached
@loop
    LDA (SOURCE_ADDR),Y
    CMP #$00
    BEQ @return
    STA (DESTINATION_ADDR),y
    INY
    JMP @loop

@return
    RTS

// ========================================

EDITOR

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
    JMP @testRegister0200

@shiftPressed
    LDA #1
    STA shiftPressed

@testRegister0200
    LDA $0200                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0201

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

@testRegister0201
    LDA $0201                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0202

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

@testRegister0202
    LDA $0202                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0203

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

@testRegister0203
    LDA $0203                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0204

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

@testRegister0204
    LDA $0204                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0205

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

@testRegister0205
    LDA $0205                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0206

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

@testRegister0206
    LDA $0206                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0207

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

@testRegister0207
    LDA $0207                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0208

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

@testRegister0208
    LDA $0208                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @testRegister0209

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

@testRegister0209
    LDA $0209                       // skip to next byte if everything is 0
    CMP #$00
    BEQ @NoKeypress

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
    LDA #$11                            // ASCII DEVICE CONTROL 1
    JMP @continue
@ArrowRight
    LDA #$12                            // ASCII DEVICE CONTROL 2
    JMP @continue
@ArrowUp
    LDA #$13                            // ASCII DEVICE CONTROL 3
    JMP @continue
@ArrowDown
    LDA #$14                            // ASCII DEVICE CONTROL 4
    JMP @continue
@Enter
    LDA #$0A                            // ASCII LINE FEED
    JMP @continue
@Backspace
    LDA #$08                            // ASCII BACKSPACE
    JMP @continue
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
    CMP #$00
    BEQ @return
    JSR ADD_CHAR_TO_BUFFER

@return
    RTS

// ========================================

keyboardBuffer .storage 16, $00                 // 16 bytes of keyboardBuffer
keyboardBufferPos .byte $00

// ========================================

ADD_CHAR_TO_BUFFER
/*     BRK
    NOP */
    LDX keyboardBufferPos                       // store char in keyboard buffer
    STA keyboardBuffer,X
    INC keyboardBufferPos                       // check for buffer overrun
    LDA keyboardBufferPos
    CMP #16
    BNE @return
@reset                                          // buffer overrun
    LDA #0
    STA keyboardBufferPos
@return
    RTS

// ========================================

GET_CHAR_FROM_BUFFER
    LDX keyboardBufferPos                       // if buffer is empty return $00 byte
    CPX #0
    BEQ @bufferEmpty
    LDA keyboardBuffer                          // load 1st char from keyboard input buffer
@shrinkBuffer
    PHA                                         // push A to stack
    LDX #0                                      // remove char from input buffer by
    LDY #1                                      // shifting all chars one byte to the left
@loop
    LDA keyboardBuffer,Y
    STA keyboardBuffer,X
    INX
    INY
    CPX keyboardBufferPos
    BNE @loop
    DEC keyboardBufferPos                       // reduce buffer size by one
    PLA                                         // pull A from stack
    JMP @return
@bufferEmpty
    LDA #$00
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

// calculate current cur pos

// Affects: A, Y
// Preserves: X

CALCULATE_CUR_POS
    LDA #<$0400
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
@return
    RTS

// ========================================

// print char stored in A to screen and increment cursor

// Affects: X
// Preserves: A, Y

PRINT_CHAR
    PHA                                         // store A to stack
    JSR CALCULATE_CUR_POS
@printChar
    PLA                                         // get current char stored in A
    LDX #0
    STA (TMP_CURSOR,X)                          // print char to screen
@return
    RTS

// ========================================

// prints the string with address $yyxx == $$hhll

// Affects: A, Y
// Preserves: X

PRINT_STRING
    TYA
    PHA
    JSR CALCULATE_CUR_POS
    PLA
    TAY
    STX TMP_POINTER
    STY TMP_POINTER + 1

    LDY #0
@loop
    LDA (TMP_POINTER),Y
    CMP #$00
    BEQ @return
    STA (TMP_CURSOR),Y                          // print char to screen
    INY
    JMP @loop

@return
    RTS

// ========================================

// Affects: A
// Preserves: XY

tmpCharOnCurPos .byte $00

GET_CHAR_ON_CUR_POS
    TYA
    PHA
    JSR CALCULATE_CUR_POS
    PLA
    TAY
@getChar
    TXA
    PHA
    LDX #0
    LDA (TMP_CURSOR,X)                          // get char from current cursor position
    STA tmpCharOnCurPos
    PLA
    TAX
    LDA tmpCharOnCurPos
@return
    RTS

// ========================================

INCREMENT_CURSOR

// Affects: XY
// Preserves: A

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

DECREMENT_CURSOR

// Affects: XY
// Preserves: A

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
    