// ========================================

#importonce 

#import "../constants.asm"

// ========================================

.label lastKeypress       = $8003
.label currentKeypress    = $8004

// ========================================

keyboardBuffer: .fill 16, $00           // 16 bytes of keyboardBuffer
keyboardBufferPos: .byte $00

shiftPressed: .byte $00

// ========================================

readKeyboard:                           // check all bits of $0200 - $0209 (hardware keyboard registers)
    lda $0205                           // check if shift is pressed
    and #%00000001
    bne !shiftPressed+
    lda #0
    sta shiftPressed
    jmp !testRegister0200+

!shiftPressed:
    lda #1
    sta shiftPressed

!testRegister0200:
    lda $0200                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0201+

    lda $0200                           // test all other keys
    and #%00000001
    bne !KeyA+
    lda $0200
    and #%00000010
    bne !KeyB+
    lda $0200
    and #%00000100
    bne !KeyC+
    lda $0200
    and #%00001000
    bne !KeyD+
    lda $0200
    and #%00010000
    bne !KeyE+
    lda $0200
    and #%00100000
    bne !KeyF+
    lda $0200
    and #%01000000
    bne !KeyG+
    lda $0200
    and #%10000000
    bne !KeyH+

!KeyA:
    lda #$41
    jmp !continue+
!KeyB:
    lda #$42
    jmp !continue+
!KeyC:
    lda #$43
    jmp !continue+
!KeyD:
    lda #$44
    jmp !continue+
!KeyE:
    lda #$45
    jmp !continue+
!KeyF:
    lda #$46
    jmp !continue+
!KeyG:
    lda #$47
    jmp !continue+
!KeyH:
    lda #$48
    jmp !continue+

!testRegister0201:
    lda $0201                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0202+

    lda $0201
    and #%00000001
    bne !KeyI+
    lda $0201
    and #%00000010
    bne !KeyJ+
    lda $0201
    and #%00000100
    bne !KeyK+
    lda $0201
    and #%00001000
    bne !KeyL+
    lda $0201
    and #%00010000
    bne !KeyM+
    lda $0201
    and #%00100000
    bne !KeyN+
    lda $0201
    and #%01000000
    bne !KeyO+
    lda $0201
    and #%10000000
    bne !KeyP+

!KeyI:
    lda #$49
    jmp !continue+
!KeyJ:
    lda #$4A
    jmp !continue+
!KeyK:
    lda #$4B
    jmp !continue+
!KeyL:
    lda #$4C
    jmp !continue+
!KeyM:
    lda #$4D
    jmp !continue+
!KeyN:
    lda #$4E
    jmp !continue+
!KeyO:
    lda #$4F
    jmp !continue+
!KeyP:
    lda #$50
    jmp !continue+

!testRegister0202:
    lda $0202                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0203+

    lda $0202
    and #%00000001
    bne !KeyQ+
    lda $0202
    and #%00000010
    bne !KeyR+
    lda $0202
    and #%00000100
    bne !KeyS+
    lda $0202
    and #%00001000
    bne !KeyT+
    lda $0202
    and #%00010000
    bne !KeyU+
    lda $0202
    and #%00100000
    bne !KeyV+
    lda $0202
    and #%01000000
    bne !KeyW+
    lda $0202
    and #%10000000
    bne !KeyX+

!KeyQ:
    lda #$51
    jmp !continue+
!KeyR:
    lda #$52
    jmp !continue+
!KeyS:
    lda #$53
    jmp !continue+
!KeyT:
    lda #$54
    jmp !continue+
!KeyU:
    lda #$55
    jmp !continue+
!KeyV:
    lda #$56
    jmp !continue+
!KeyW:
    lda #$57
    jmp !continue+
!KeyX:
    lda #$58
    jmp !continue+

!testRegister0203:
    lda $0203                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0204+

    lda $0203
    and #%00000001
    bne !KeyY+
    lda $0203
    and #%00000010
    bne !KeyZ+
    lda $0203
    and #%00000100
    bne !Digit1+
    lda $0203
    and #%00001000
    bne !Digit2+
    lda $0203
    and #%00010000
    bne !Digit3+
    lda $0203
    and #%00100000
    bne !Digit4+
    lda $0203
    and #%01000000
    bne !Digit5+
    lda $0203
    and #%10000000
    bne !Digit6+

!KeyY:
    lda #$59
    jmp !continue+
!KeyZ:
    lda #$5A
    jmp !continue+
!Digit1:
    lda #$31
    jmp !continue+
!Digit2:
    lda #$32
    jmp !continue+
!Digit3:
    lda #$33
    jmp !continue+
!Digit4:
    lda #$34
    jmp !continue+
!Digit5:
    lda #$35
    jmp !continue+
!Digit6:
    lda #$36
    jmp !continue+

!testRegister0204:
    lda $0204                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0205+

    lda $0204
    and #%00000001
    bne !Digit7+
    lda $0204
    and #%00000010
    bne !Digit8+
    lda $0204
    and #%00000100
    bne !Digit9+
    lda $0204
    and #%00001000
    bne !Digit0+
    lda $0204
    and #%00010000
    bne !Minus+
    lda $0204
    and #%00100000
    bne !Equal+
    lda $0204
    and #%01000000
    bne !Comma+
    lda $0204
    and #%10000000
    bne !Period+

!Digit7:
    lda #$37
    jmp !continue+
!Digit8:
    lda #$38
    jmp !continue+
!Digit9:
    lda #$39
    jmp !continue+
!Digit0:
    lda #$30
    jmp !continue+
!Minus:
    lda #$2D
    jmp !continue+
!Equal:
    lda #$3D
    jmp !continue+
!Comma:
    lda #$2C
    jmp !continue+
!Period:
    lda #$2E
    jmp !continue+

!testRegister0205:
    lda $0205                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0206+

//    lda $0205
//    and #%00000001
//    bne !Shift
    lda $0205
    and #%00000010
    bne !Control+
    lda $0205
    and #%00000100
    bne !Alt+
    lda $0205
    and #%00001000
    bne !Meta+
    lda $0205
    and #%00010000
    bne !Tab+
    lda $0205
    and #%00100000
    bne !CapsLock+
    lda $0205
    and #%01000000
    bne !Space+
    lda $0205
    and #%10000000
    bne !Slash+

// !Shift:
//    lda #ASCII_SPACE
//    jmp !continue+
!Control:
    lda #$00
    jmp !continue+
!Alt:
    lda #$00
    jmp !continue+
!Meta:
    lda #$00
    jmp !continue+
!Tab:
    lda #$00
    jmp !continue+
!CapsLock:
    lda #$00
    jmp !continue+
!Space:
    lda #asciiSpace
    jmp !continue+
!Slash:
    lda #$2F
    jmp !continue+

!testRegister0206:
    lda $0206                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0207+

    lda $0206
    and #%00000001
    bne !ArrowLeft+
    lda $0206
    and #%00000010
    bne !ArrowRight+
    lda $0206
    and #%00000100
    bne !ArrowUp+
    lda $0206
    and #%00001000
    bne !ArrowDown+
    lda $0206
    and #%00010000
    bne !Enter+
    lda $0206
    and #%00100000
    bne !Backspace+
    lda $0206
    and #%01000000
    bne !Escape+
    lda $0206
    and #%10000000
    bne !Backslash+

!ArrowLeft:
    lda #$11                            // ASCII DEVICE CONTROL 1
    jmp !continue+
!ArrowRight:
    lda #$12                            // ASCII DEVICE CONTROL 2
    jmp !continue+
!ArrowUp:
    lda #$13                            // ASCII DEVICE CONTROL 3
    jmp !continue+
!ArrowDown:
    lda #$14                            // ASCII DEVICE CONTROL 4
    jmp !continue+
!Enter:
    lda #$0A                            // ASCII LINE FEED
    jmp !continue+
!Backspace:
    lda #$08                            // ASCII BACKSPACE
    jmp !continue+
!Escape:
    lda #$00
    jmp !continue+
!Backslash:
    lda #$5C
    jmp !continue+

!testRegister0207:
    lda $0207                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0208+

    lda $0207
    and #%00000001
    bne !F1+
    lda $0207
    and #%00000010
    bne !F2+
    lda $0207
    and #%00000100
    bne !F3+
    lda $0207
    and #%00001000
    bne !F4+
    lda $0207
    and #%00010000
    bne !F5+
    lda $0207
    and #%00100000
    bne !F6+
    lda $0207
    and #%01000000
    bne !F7+
    lda $0207
    and #%10000000
    bne !F8+

!F1:
    lda #$00
    jmp !continue+
!F2:
    lda #$00
    jmp !continue+
!F3:
    lda #$00
    jmp !continue+
!F4:
    lda #$00
    jmp !continue+
!F5:
    lda #$00
    jmp !continue+
!F6:
    lda #$00
    jmp !continue+
!F7:
    lda #$00
    jmp !continue+
!F8:
    lda #$00
    jmp !continue+

!testRegister0208:
    lda $0208                           // skip to next byte if everything is 0
    cmp #$00
    beq !testRegister0209+

    lda $0208
    and #%00000001
    bne !F9+
    lda $0208
    and #%00000010
    bne !F10+
    lda $0208
    and #%00000100
    bne !Semicolon+
    lda $0208
    and #%00001000
    bne !Quote+
    lda $0208
    and #%00010000
    bne !BracketLeft+
    lda $0208
    and #%00100000
    bne !BracketRight+
    lda $0208
    and #%01000000
    bne !Backquote+
    lda $0208
    and #%10000000
    bne !IntlBackslash+

!F9:
    lda #$00
    jmp !continue+
!F10:
    lda #$00
    jmp !continue+
!Semicolon:
    lda #$3B
    jmp !continue+
!Quote:
    lda #$27
    jmp !continue+
!BracketLeft:
    lda #$5B
    jmp !continue+
!BracketRight:
    lda #$5D
    jmp !continue+
!Backquote:
    lda #$60
    jmp !continue+
!IntlBackslash:
    lda #$00
    jmp !continue+

!testRegister0209:
    lda $0209                           // skip to next byte if everything is 0
    cmp #$00
    beq !NoKeypress+

    lda $0209
    and #%00000001
    bne !PageUp+
    lda $0209
    and #%00000010
    bne !PageDown+
    lda $0209
    and #%00000100
    bne !Home+
    lda $0209
    and #%00001000
    bne !End+
    lda $0209
    and #%00010000
    bne !Insert+
    lda $0209
    and #%00100000
    bne !Delete+
    lda $0209
    and #%01000000
    bne !PrintScreen+
    lda $0209
    and #%10000000
    bne !XXX+

    jmp !NoKeypress+

!PageUp:
    lda #$00
    jmp !continue+
!PageDown:
    lda #$00
    jmp !continue+
!Home:
    lda #$00
    jmp !continue+
!End:
    lda #$00
    jmp !continue+
!Insert:
    lda #$00
    jmp !continue+
!Delete:
    lda #$00
    jmp !continue+
!PrintScreen:
    lda #$00
    jmp !continue+
!XXX:
    lda #$00
    jmp !continue+

!NoKeypress:
    lda $00
    sta currentKeypress
    sta lastKeypress
    jmp !return+

!continue:
    cmp #$41                                // check if key is a shiftable character 
    bcc !upperCase+                         // if >=$41 and <=$5A
    cmp #$5A                                // not if <$41 or >$5A
    beq !lowerCase+
    bcs !upperCase+
!lowerCase:
    ldx shiftPressed                        // if shift is pressed add $20 to key which
    cpx #0                                  // effectively turns uppercase into lowercase
    bne !upperCase+
    clc
    adc #$20
!upperCase:
    sta currentKeypress                     // a contains keypress
    cmp lastKeypress                        // if previous key is still pressed do nothing
    beq !return+
    sta lastKeypress                        // store current keypress in last keypress
    cmp #$00
    beq !return+
    jsr addCharToBuf

!return:
    rts

// ========================================

addCharToBuf:
    ldx keyboardBufferPos                   // store char in keyboard buffer
    sta keyboardBuffer,X
    inc keyboardBufferPos                   // check for buffer overrun
    lda keyboardBufferPos
    cmp #16
    bne !return+
!reset:                                     // buffer overrun
    lda #0
    sta keyboardBufferPos
!return:
    rts

// ========================================

getCharFromBuf:
    ldx keyboardBufferPos                   // if buffer is empty return $00 byte
    cpx #0
    beq !bufferEmpty+
    lda keyboardBuffer                      // load 1st char from keyboard input buffer
!shrinkBuffer:
    pha                                     // push A to stack
    ldx #0                                  // remove char from input buffer by
    ldy #1                                  // shifting all chars one byte to the left
!loop:
    lda keyboardBuffer,Y
    sta keyboardBuffer,X
    inx
    iny
    cpx keyboardBufferPos
    bne !loop-
    dec keyboardBufferPos                   // reduce buffer size by one
    pla                                     // pull A from stack
    jmp !return+
!bufferEmpty:
    lda #$00
!return:
    rts

// ========================================