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

testColorTableColorMode4:
    // Values in RGBA
    .byte 255, 0, 0, 255                    // color 0 (red)
    .byte 0, 255, 0, 255                    // color 1 (green)
    .byte 0, 0, 255, 255                    // color 2 (blue)
    .byte 80, 80, 80, 255                   // color 3 (grey)

testTileSetTileMode8ColorMode4:
    .for (var y = 0; y < 8; y++) {
        .byte %00011011                     // red, green, blue, grey
        .byte %00011011                     // red, green, blue, grey
    }
    .for (var y = 0; y < 8; y++) {
        .byte %00000000                     // red, red, red, red
        .byte %11111111                     // grey, grey, grey, grey
    }
    .for (var y = 0; y < 8; y++) {
        .byte %01010101                     // green, green, green, green
        .byte %10101010                     // blue, blue, blue, blue
    }
    .for (var y = 0; y < 8; y++) {
        .byte %11001100                     // grey, red, grey, red
        .byte %11001100                     // grey, red, grey, red
    }

testTileSetTileMode16ColorMode4:
    .for (var y = 0; y < 16; y++) {
        .byte %00011011                     // red, green, blue, grey
        .byte %00011011                     // red, green, blue, grey
        .byte %00000000                     // red, red, red, red
        .byte %11111111                     // grey, grey, grey, grey
    }
    .for (var y = 0; y < 16; y++) {
        .byte %00000000                     // red, red, red, red
        .byte %11111111                     // grey, grey, grey, grey
        .byte %01010101                     // green, green, green, green
        .byte %10101010                     // blue, blue, blue, blue
    }
    .for (var y = 0; y < 16; y++) {
        .byte %01010101                     // green, green, green, green
        .byte %10101010                     // blue, blue, blue, blue
        .byte %11001100                     // grey, red, grey, red
        .byte %11001100                     // grey, red, grey, red
    }
    .for (var y = 0; y < 16; y++) {
        .byte %11001100                     // grey, red, grey, red
        .byte %11001100                     // grey, red, grey, red
        .byte %00011011                     // red, green, blue, grey
        .byte %00011011                     // red, green, blue, grey
    }

testColorMode:
    lda #colMode4
    sta colorMode

    lda #<testColorTableColorMode4
    sta colorTableAddr
    lda #>testColorTableColorMode4
    sta colorTableAddr+1

    lda #tileMode8 | (tileOrientLeftRight << 7)
    sta tileModeOrientation

    lda #screenWidth
    sta tileMapWidth

    lda #screenHeight
    sta tileMapHeight

    lda #<screenMemStart
    sta tileMapAddr
    lda #>screenMemStart
    sta tileMapAddr+1

    lda #<testTileSetTileMode8ColorMode4
    sta tileSetAddr
    lda #>testTileSetTileMode8ColorMode4
    sta tileSetAddr+1
    
    lda #4
    sta tileSetLength

    // --------------------

    lda #0                                  // 1st line at pos 1,3,5 and 7
    sta screenMemStart + 1
    lda #1
    sta screenMemStart + 3
    lda #2
    sta screenMemStart + 5
    lda #3
    sta screenMemStart + 7

    lda #0                                  // 2nd line at pos 2,4,6 and 8 (because of offset 1)
    sta screenMemStart + screenWidth + 1 + 1
    lda #1
    sta screenMemStart + screenWidth + 1 + 3
    lda #2
    sta screenMemStart + screenWidth + 1 + 5
    lda #3
    sta screenMemStart + screenWidth + 1 + 7

    // --------------------

!loop:
    jsr getCharFromBuf
    cmp #$00                                // no input
    beq !loop-

    // --------------------

    lda #tileMode16 | (tileOrientLeftRight << 7)
    sta tileModeOrientation

    lda #<testTileSetTileMode16ColorMode4
    sta tileSetAddr
    lda #>testTileSetTileMode16ColorMode4
    sta tileSetAddr+1

    // --------------------

    lda #0                                  // 1st line at pos 1,3,5 and 7
    sta screenMemStart + 1
    lda #1
    sta screenMemStart + 3
    lda #2
    sta screenMemStart + 5
    lda #3
    sta screenMemStart + 7

    lda #0                                  // 2nd line at pos 2,4,6 and 8 (because of offset 1)
    sta screenMemStart + screenWidth + 1 + 1
    lda #1
    sta screenMemStart + screenWidth + 1 + 3
    lda #2
    sta screenMemStart + screenWidth + 1 + 5
    lda #3
    sta screenMemStart + screenWidth + 1 + 7

    // --------------------

!loop:
    jsr getCharFromBuf
    cmp #$00                                // no input
    beq !loop-

    // --------------------

!return:
    rts

// ========================================