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
ctrlPressed: .byte $00
altPressed: .byte $00
metaPressed: .byte $00

// ========================================

readKeyboard:                           // check all bits of $0200 - $0209 (hardware keyboard registers)
    lda #$00                            // reset modifiers
    sta shiftPressed
    sta ctrlPressed
    sta altPressed
    sta metaPressed

    lda $0209                           // check if shift is pressed
    and #%00010000
    beq !continue+
    lda #$FF
    sta shiftPressed

!continue:
    lda $0209                           // check if control is pressed
    and #%00100000
    beq !continue+
    lda #$FF
    sta ctrlPressed

!continue:
    lda $0209                           // check if alt is pressed
    and #%01000000
    beq !continue+
    lda #$FF
    sta altPressed

!continue:
    lda $0209                           // check if meta is pressed
    and #%10000000
    beq !testRegister0200+
    lda #$FF
    sta metaPressed

!testRegister0200:
    lda $0200                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0201+
!continue:
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
    lda #$61
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$41
!notShifted:
    jmp !continueReadKeyboard+

!KeyB:
    lda #$62
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$42
!notShifted:
    jmp !continueReadKeyboard+

!KeyC:
    lda #$63
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$43
!notShifted:
    jmp !continueReadKeyboard+

!KeyD:
    lda #$64
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$44
!notShifted:
    jmp !continueReadKeyboard+

!KeyE:
    lda #$65
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$45
!notShifted:
    jmp !continueReadKeyboard+

!KeyF:
    lda #$66
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$46
!notShifted:
    jmp !continueReadKeyboard+

!KeyG:
    lda #$67
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$47
!notShifted:
    jmp !continueReadKeyboard+

!KeyH:
    lda #$68
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$48
!notShifted:
    jmp !continueReadKeyboard+

!testRegister0201:
    lda $0201                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0202+
!continue:
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
    lda #$69
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$49
!notShifted:
    jmp !continueReadKeyboard+

!KeyJ:
    lda #$6A
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$4A
!notShifted:
    jmp !continueReadKeyboard+

!KeyK:
    lda #$6B
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$4B
!notShifted:
    jmp !continueReadKeyboard+

!KeyL:
    lda #$6C
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$4C
!notShifted:
    jmp !continueReadKeyboard+

!KeyM:
    lda #$6D
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$4D
!notShifted:
    jmp !continueReadKeyboard+

!KeyN:
    lda #$6E
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$4E
!notShifted:
    jmp !continueReadKeyboard+

!KeyO:
    lda #$6F
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$4F
!notShifted:
    jmp !continueReadKeyboard+

!KeyP:
    lda #$70
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$50
!notShifted:
    jmp !continueReadKeyboard+

!testRegister0202:
    lda $0202                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0203+
!continue:
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
    lda #$71
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$51
!notShifted:
    jmp !continueReadKeyboard+

!KeyR:
    lda #$72
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$52
!notShifted:
    jmp !continueReadKeyboard+

!KeyS:
    lda #$73
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$53
!notShifted:
    jmp !continueReadKeyboard+

!KeyT:
    lda #$74
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$54
!notShifted:
    jmp !continueReadKeyboard+

!KeyU:
    lda #$75
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$55
!notShifted:
    jmp !continueReadKeyboard+

!KeyV:
    lda #$76
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$56
!notShifted:
    jmp !continueReadKeyboard+

!KeyW:
    lda #$77
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$57
!notShifted:
    jmp !continueReadKeyboard+

!KeyX:
    lda #$78
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$58
!notShifted:
    jmp !continueReadKeyboard+

!testRegister0203:
    lda $0203                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0204+
!continue:
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
    lda #$79
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$59
!notShifted:
    jmp !continueReadKeyboard+

!KeyZ:
    lda #$7A
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$5A
!notShifted:
    jmp !continueReadKeyboard+

!Digit1:
    lda #$31
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$21
!notShifted:
    jmp !continueReadKeyboard+

!Digit2:
    lda #$32
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$40
!notShifted:
    jmp !continueReadKeyboard+

!Digit3:
    lda #$33
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$23
!notShifted:
    jmp !continueReadKeyboard+

!Digit4:
    lda #$34
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$24
!notShifted:
    jmp !continueReadKeyboard+

!Digit5:
    lda #$35
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$25
!notShifted:
    jmp !continueReadKeyboard+

!Digit6:
    lda #$36
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$5E
!notShifted:
    jmp !continueReadKeyboard+

!testRegister0204:
    lda $0204                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0205+
!continue:
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
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$26
!notShifted:
    jmp !continueReadKeyboard+

!Digit8:
    lda #$38
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$2A
!notShifted:
    jmp !continueReadKeyboard+

!Digit9:
    lda #$39
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$28
!notShifted:
    jmp !continueReadKeyboard+

!Digit0:
    lda #$30
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$29
!notShifted:
    jmp !continueReadKeyboard+

!Minus:
    lda #$2D
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$5F
!notShifted:
    jmp !continueReadKeyboard+

!Equal:
    lda #$3D
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$2B
!notShifted:
    jmp !continueReadKeyboard+

!Comma:
    lda #$2C
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$3C
!notShifted:
    jmp !continueReadKeyboard+

!Period:
    lda #$2E
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$3E
!notShifted:
    jmp !continueReadKeyboard+

!testRegister0205:
    lda $0205                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0206+
!continue:
    lda $0205
    and #%00000001
    bne !ArrowLeft+
    lda $0205
    and #%00000010
    bne !ArrowRight+
    lda $0205
    and #%00000100
    bne !ArrowUp+
    lda $0205
    and #%00001000
    bne !ArrowDown+
    lda $0205
    and #%00010000
    bne !Enter+
    lda $0205
    and #%00100000
    bne !Backspace+
    lda $0205
    and #%01000000
    bne !Escape+
    lda $0205
    and #%10000000
    bne !Backslash+

!ArrowLeft:
    lda #$11                            // ASCII DEVICE CONTROL 1
    jmp !continueReadKeyboard+
!ArrowRight:
    lda #$12                            // ASCII DEVICE CONTROL 2
    jmp !continueReadKeyboard+
!ArrowUp:
    lda #$13                            // ASCII DEVICE CONTROL 3
    jmp !continueReadKeyboard+
!ArrowDown:
    lda #$14                            // ASCII DEVICE CONTROL 4
    jmp !continueReadKeyboard+
!Enter:
    lda #$0A                            // ASCII LINE FEED
    jmp !continueReadKeyboard+
!Backspace:
    lda #$08                            // ASCII BACKSPACE
    jmp !continueReadKeyboard+
!Escape:
    lda #$00
    jmp !continueReadKeyboard+

!Backslash:
    lda #$5C
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$7C
!notShifted:
    jmp !continueReadKeyboard+

!testRegister0206:
    lda $0206                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0207+
!continue:
    lda $0206
    and #%00000001
    bne !F1+
    lda $0206
    and #%00000010
    bne !F2+
    lda $0206
    and #%00000100
    bne !F3+
    lda $0206
    and #%00001000
    bne !F4+
    lda $0206
    and #%00010000
    bne !F5+
    lda $0206
    and #%00100000
    bne !F6+
    lda $0206
    and #%01000000
    bne !F7+
    lda $0206
    and #%10000000
    bne !F8+

!F1:
    lda #$00
    jmp !continueReadKeyboard+
!F2:
    lda #$00
    jmp !continueReadKeyboard+
!F3:
    lda #$00
    jmp !continueReadKeyboard+
!F4:
    lda #$00
    jmp !continueReadKeyboard+
!F5:
    lda #$00
    jmp !continueReadKeyboard+
!F6:
    lda #$00
    jmp !continueReadKeyboard+
!F7:
    lda #$00
    jmp !continueReadKeyboard+
!F8:
    lda #$00
    jmp !continueReadKeyboard+

!testRegister0207:
    lda $0207                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0208+
!continue:
    lda $0207
    and #%00000001
    bne !F9+
    lda $0207
    and #%00000010
    bne !F10+
    lda $0207
    and #%00000100
    bne !Semicolon+
    lda $0207
    and #%00001000
    bne !Quote+
    lda $0207
    and #%00010000
    bne !BracketLeft+
    lda $0207
    and #%00100000
    bne !BracketRight+
    lda $0207
    and #%01000000
    bne !Backquote+
    lda $0207
    and #%10000000
    bne !IntlBackslash+

!F9:
    lda #$00
    jmp !continueReadKeyboard+
!F10:
    lda #$00
    jmp !continueReadKeyboard+

!Semicolon:
    lda #$3B
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$3A
!notShifted:
    jmp !continueReadKeyboard+

!Quote:
    lda #$27
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$22
!notShifted:
    jmp !continueReadKeyboard+

!BracketLeft:
    lda #$5B
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$7B
!notShifted:
    jmp !continueReadKeyboard+

!BracketRight:
    lda #$5D
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$7D
!notShifted:
    jmp !continueReadKeyboard+

!Backquote:
    lda #$60
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$7E
!notShifted:
    jmp !continueReadKeyboard+

!IntlBackslash:
    lda #$00
    jmp !continueReadKeyboard+

!testRegister0208:
    lda $0208                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !testRegister0209+
!continue:
    lda $0208
    and #%00000001
    bne !PageUp+
    lda $0208
    and #%00000010
    bne !PageDown+
    lda $0208
    and #%00000100
    bne !Home+
    lda $0208
    and #%00001000
    bne !End+
    lda $0208
    and #%00010000
    bne !Insert+
    lda $0208
    and #%00100000
    bne !Delete+
    lda $0208
    and #%01000000
    bne !PrintScreen+
    lda $0208
    and #%10000000
    bne !Slash+

!PageUp:
    lda #$00
    jmp !continueReadKeyboard+
!PageDown:
    lda #$00
    jmp !continueReadKeyboard+
!Home:
    lda #$00
    jmp !continueReadKeyboard+
!End:
    lda #$00
    jmp !continueReadKeyboard+
!Insert:
    lda #$00
    jmp !continueReadKeyboard+
!Delete:
    lda #$00
    jmp !continueReadKeyboard+
!PrintScreen:
    lda #$00
    jmp !continueReadKeyboard+

!Slash:
    lda #$2F
    ldx shiftPressed
    cpx #$00
    beq !notShifted+
    lda #$3F
!notShifted:
    jmp !continueReadKeyboard+

!testRegister0209:
    lda $0209                           // skip to next byte if everything is 0
    cmp #$00
    bne !continue+
    jmp !NoKeypress+
!continue:
    lda $0209
    and #%00000001
    bne !Tab+
    lda $0209
    and #%00000010
    bne !CapsLock+
    lda $0209
    and #%00000100
    bne !Space+
    lda $0209
    and #%00001000
    bne !XXX+
    lda $0209
    and #%00010000
    bne !Shift+
    lda $0209
    and #%00100000
    bne !Control+
    lda $0209
    and #%01000000
    bne !Alt+
    lda $0209
    and #%10000000
    bne !Meta+

    jmp !NoKeypress+

!Tab:
    lda #$00
    jmp !continueReadKeyboard+
!CapsLock:
    lda #$00
    jmp !continueReadKeyboard+
!Space:
    lda #asciiSpace
    jmp !continueReadKeyboard+
!XXX:
    lda #$00
    jmp !continueReadKeyboard+
!Shift:
    lda #$00
    jmp !continueReadKeyboard+
!Control:
    lda #$00
    jmp !continueReadKeyboard+
!Alt:
    lda #$00
    jmp !continueReadKeyboard+
!Meta:
    lda #$00
    jmp !continueReadKeyboard+


!NoKeypress:
    lda $00
    sta currentKeypress
    sta lastKeypress
    jmp !return+

!continueReadKeyboard:
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
    sta keyboardBuffer,x
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
    sta keyboardBuffer,x
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