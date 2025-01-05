// ========================================

#importonce

#import "../labels.asm"
#import "../constants.asm"
#import "terminal.asm"

// ========================================

header: .text @"  bono v0.1    New Buffer\$00"
footer1: .text @"~^G~Help  ~^O~Write Out  ~^K~Cut  \$00"
footer2: .text @"~^X~Exit  ~^R~Read File  ~^U~Paste\$00"

// ========================================

.const editorStartHeader    = screenMemStart
.const editorStartFooter1   = screenMemStart+(screenWidth*(screenHeight-2))
.const editorStartFooter2   = screenMemStart+(screenWidth*(screenHeight-1))
.const editorHeaderHeight   = 2
.const editorFooterHeight   = 3
.const editorLineNumbers    = 3
.const editorLineNumberGap  = 1
.const editorStatLineIndex  = 27
.const editorStartX         = editorLineNumbers+editorLineNumberGap
.const editorStartY         = editorHeaderHeight
.const editorHeight         = screenHeight-editorHeaderHeight-editorFooterHeight
.const editorWidth          = screenWidth-editorStartX
.const editorStartStatLine  = screenMemStart+(screenWidth*editorStatLineIndex)
.const editorFilenameOffset = 15

// ========================================

.label lineLengthCache      = $0a00         // max 256 lines
.label editorCache          = $0b00         // currently each line has max width = editor width

// ========================================

currentLine: .byte $00                      // max 256 lines per document
currentLineCur: .byte $00                   // max line width depends on screen width

currentPrintableChar: .byte $00

// ========================================

editorStart:
    lda #$00
    jsr fillScreen

    jsr printHeader
    jsr printFooter

    jsr clearEditorCache
    jsr clearLineLengthCache

    lda #0
    sta currentLine
    sta currentLineCur

    lda currentLine
    clc
    adc #1                                  // always start at 1
    jsr printLineNumbers

    lda #0
    sta curPosX
    lda #editorHeaderHeight
    sta curPosY

    lda #editorStartX
    sta curPosX
    lda #editorStartY
    sta curPosY

    jmp !printCursor+

!editorLoop:
    jsr getCharFromBuf
    cmp #$00                                // no input
    beq !editorLoop-
    cmp #$08                                // ASCII BACKSPACE
    beq !backspaceJump+
    cmp #$0A                                // ASCII LINE FEED
    beq !enterJump+
    cmp #$11                                // ASCII DEVICE CONTROL 1 = ARROW LEFT
    beq !arrowLeftJump+
    cmp #$12                                // ASCII DEVICE CONTROL 2 = ARROW RIGHT
    beq !arrowRightJump+
    cmp #$13                                // ASCII DEVICE CONTROL 3 = ARROW UP
    beq !arrowUpJump+
    cmp #$14                                // ASCII DEVICE CONTROL 4 = ARROW DOWN
    beq !arrowDownJump+
    jmp !jumpTableEnd+
!backspaceJump:
    jmp !backspace+
!enterJump:
    jmp !enter+
!arrowLeftJump:
    jmp !arrowLeft+
!arrowRightJump:
    jmp !arrowRight+
!arrowUpJump:
    jmp !arrowUp+
!arrowDownJump:
    jmp !arrowDown+
!jumpTableEnd:
    sta currentPrintableChar
    ldx ctrlPressed                         // check for special commands
    cpx #$FF
    bne !printableChar+
    cmp #'x'
    beq !ctrlX+
    cmp #'o'
    beq !ctrlO+
    cmp #'r'
    beq !ctrlR+

    jmp !printableChar+

!ctrlX:
    jmp editorReturn

!ctrlO:
    jsr commandCtrlO
    jmp !editorLoop-

!ctrlR:
    jsr commandCtrlR
    jmp !printCursor+

!printCursor:
    lda #charFullBlock                      // unused ASCII code is now Cursor
    jsr printChar
    jmp !editorLoop-

!printableChar:
    lda cursorChar
    jsr printChar
    jsr editorPrintableChar
    jsr getCharOnCurPos
    sta cursorChar
    jsr showEditMarker
    jmp !printCursor-
!backspace:
    lda cursorChar
    jsr printChar
    jsr editorBackspace
    jsr getCharOnCurPos
    sta cursorChar
    jsr showEditMarker
    jmp !printCursor-
!enter:
    lda cursorChar
    jsr printChar
    jsr editorEnter
    jsr getCharOnCurPos
    sta cursorChar
    jsr showEditMarker
    jmp !printCursor-
!arrowLeft:
    lda cursorChar
    jsr printChar
    jsr editorCursorLeft
    jsr getCharOnCurPos
    sta cursorChar
    jmp !printCursor-
!arrowRight:
    lda cursorChar
    jsr printChar
    jsr editorCursorRight
    jsr getCharOnCurPos
    sta cursorChar
    jmp !printCursor-
!arrowUp:
    lda cursorChar
    jsr printChar
    jsr editorCursorUp
    jsr getCharOnCurPos
    sta cursorChar
    jmp !printCursor-
!arrowDown:
    lda cursorChar
    jsr printChar
    jsr editorCursorDown
    jsr getCharOnCurPos
    sta cursorChar
    jmp !printCursor-

// ========================================

saveLinesCounter: .byte $00

commandCtrlO:
    lda curPosX
    pha
    lda curPosY
    pha

    jsr askFilename
    lda inpBufLen
    cmp #0
    beq !noFilename+

    jsr copyFilenameToCommandBuffer
    jsr existsFilesystemObject
    cmp #$FF
    beq !fsObjectExists+
    jmp !saveNewFile+

!fsObjectExists:
    jsr copyFilenameToCommandBuffer
    jsr isFile
    cmp #$FF
    beq !fileExists+
    lda #errCodeIsDir
    jsr editorPrintError
    jmp !return+

!fileExists:
    lda #errCodeFileExists
    jsr editorPrintError
    jmp !return+

!printError:
    lda storageComLastErr
    jsr editorPrintError
    jmp !return+

!saveNewFile:
    jsr copyFilenameToCommandBuffer
    jsr createFile
    cmp #$FF
    bne !printError-

    lda #0
    sta saveLinesCounter
!loop:
    ldx saveLinesCounter
    lda lineLengthCache,x
    cmp #$00
    beq !finished+
    jsr copyFilenameToCommandBuffer
    jsr copyEditorCacheToReadWriteBuffer
    jsr appendFileContent
    cmp #$FF
    bne !printError-
    inc saveLinesCounter
    lda saveLinesCounter
    cmp editorHeight
    beq !finished+
    jmp !loop-

!finished:
    jsr updateFilename
    jsr printXxxLinesWritten
    jsr clearEditMarker

!noFilename:
!return:
    pla
    sta curPosY
    pla
    sta curPosX
    rts

// ========================================

readLinesCounter: .byte $00

commandCtrlR:
    lda #0
    sta readLinesCounter
    sta currentLine
    sta currentLineCur

    jsr askFilename
    lda inpBufLen
    cmp #0
    beq !noFilename+

    jsr copyFilenameToCommandBuffer
    jsr existsFilesystemObject
    cmp #$FF
    beq !fsObjectExists+
    jmp !noFilesystemObject+

!fsObjectExists:
    jsr copyFilenameToCommandBuffer
    jsr isFile
    cmp #$FF
    beq !fileExists+
    lda #errCodeIsDir
    jsr editorPrintError
    jmp !return+

!noFilesystemObject:
    lda #errCodeNoFileOrDir
    jsr editorPrintError
    jmp !return+

!printError:
    lda storageComLastErr
    jsr editorPrintError
    jmp !return+

!fileExists:                                // copy data into editor cache
!loop:
    jsr copyFilenameToCommandBuffer
    jsr readFileContent
    jsr copyReadWriteBufferToEditorCache

    lda tmpReadWriteBuffer
    cmp #$FF
    beq !fillScreen+

    cmp #$FF
    bne !printError-

    jmp !loop-

!fillScreen:
    lda #0
    sta currentLine
!loop:
    lda currentLine
    cmp #editorHeight
    beq !finished+
    jsr copyEditorCacheToLine
    inc currentLine
    jmp !loop-

!finished:
    lda currentLine
    jsr updateFilename
    inc readLinesCounter                    // increment read lines counter for last line (partially)
    jsr printXxxLinesRead
    jsr clearEditMarker

!noFilename:
!return:
    dec readLinesCounter
    lda readLinesCounter
    sta currentLine
    clc
    adc #editorStartY
    sta curPosY
    ldx currentLine
    lda lineLengthCache,x
    sta currentLineCur
    clc
    adc #editorStartX
    sta curPosX

    rts

// ========================================

editorPrintError:
    jsr invertColors
    jsr clearStatLine

    ldx #5
    stx curPosX
    ldy #editorStatLineIndex
    sty curPosY

    cmp #errCodeFileExists
    beq !errFileExists+
    cmp #errCodeIsDir
    beq !errIsDir+

    jmp !errorUnknown+

!errFileExists:
    ldx #<errFileExists
    ldy #>errFileExists
    jmp !printError+

!errIsDir:
    ldx #<errIsDir
    ldy #>errIsDir
    jmp !printError+

!errorUnknown:
    ldx #<errorUnknown
    ldy #>errorUnknown

!printError:
    jsr printString

!return:
    jsr invertColors
    rts

// ========================================

copyFilenameToCommandBuffer:
    lda #15
    sta curPosX
    jsr calcCurPos
    lda tmpCursor
    sta sourceAddr
    lda tmpCursor + 1
    sta sourceAddr + 1
                    
    lda #<tmpCommandBuffer+3                // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>tmpCommandBuffer+3
    sta destinationAddr + 1

    ldy #0                                  // copy filename to buffer
!loop:
    cpy inpBufLen
    beq !loopEnd+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-
!loopEnd:

!return:
    rts

// ========================================

updateFilename:
    jsr invertColors

    lda #charSpace
    ldx #0                                  // clear filename
!loop:
    cpx #screenWidth-editorFilenameOffset
    beq !loopEnd+
    sta editorStartHeader+editorFilenameOffset,x
    inx
    jmp !loop-
!loopEnd:

    lda #15
    sta curPosX
    jsr calcCurPos
    lda tmpCursor
    sta sourceAddr
    lda tmpCursor + 1
    sta sourceAddr + 1
                                            // copy header+editorFilenameOffset to destination address
    lda #<editorStartHeader+editorFilenameOffset
    sta destinationAddr
    lda #>editorStartHeader+editorFilenameOffset
    sta destinationAddr + 1

    ldy #0                                  // copy filename to header
!loop:
    cpy inpBufLen
    beq !loopEnd+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-
!loopEnd:

!return:
    jsr invertColors
    rts

// ========================================

copyEditorCacheToReadWriteBuffer:
    jsr clearReadWriteBuffer

    ldx saveLinesCounter
    lda lineLengthCache,x
    sta tmpReadWriteBuffer

    lda #<editorCache
    sta sourceAddr
    lda #>editorCache
    sta sourceAddr + 1

    ldx #0
!loop:
    cpx saveLinesCounter
    beq !loopEnd+
    lda sourceAddr
    clc
    adc #editorWidth
    sta sourceAddr
    lda sourceAddr+1
    adc #0
    sta sourceAddr+1
    inx
    jmp !loop-
!loopEnd:
                    
    lda #<tmpReadWriteBuffer+1              // copy R/W buffer to destination address + 1
    sta destinationAddr
    lda #>tmpReadWriteBuffer+1
    sta destinationAddr + 1

    ldy #0                                  // copy line to buffer
!loop:
    cpy tmpReadWriteBuffer                  // tmpReadWriteBuffer now stores the line length
    beq !loopEnd+
    lda (sourceAddr),Y

    cmp #charBulletOperator                 // replace editor symbols
    beq !replaceSpace+
    cmp #charPilcrowSign
    beq !replaceLineFeed+
    jmp !continue+
!replaceSpace:
    lda #charSpace
    jmp !continue+
!replaceLineFeed:
    lda #charLineFeed
!continue:

    sta (destinationAddr),y
    iny
    jmp !loop-
!loopEnd:

!return:
    rts

// ========================================

tmpY: .byte $00
currentLineLength: .byte $00

copyReadWriteBufferToEditorCache:
    lda #0
    sta currentLineLength

    lda #<tmpReadWriteBuffer+2              // copy R/W buffer + 2 to source address
    sta sourceAddr
    lda #>tmpReadWriteBuffer+2
    sta sourceAddr + 1

    lda #<editorCache                       // copy editor cache to destination address
    sta destinationAddr
    lda #>editorCache
    sta destinationAddr + 1

    ldx #0                                  // set destination address to current line
!loop:
    cpx readLinesCounter
    beq !loopEnd+
    lda destinationAddr
    clc
    adc #editorWidth
    sta destinationAddr
    lda destinationAddr+1
    adc #0
    sta destinationAddr+1
    inx
    jmp !loop-
!loopEnd:

    ldy #0                                  // copy buffer to line
!loop:
    cpy tmpReadWriteBuffer+1                // tmpReadWriteBuffer + 1 stores the line length
    beq !loopEnd+
    lda (sourceAddr),Y

    cmp #charSpace                          // replace editor symbols
    beq !replaceSpace+
    cmp #charLineFeed
    beq !replaceLineFeed+
    jmp !continue+
!replaceSpace:
    lda #charBulletOperator
    jmp !continue+
!replaceLineFeed:
    lda #charPilcrowSign
!continue:

    sta (destinationAddr),y
    iny
    inc currentLineLength
    cmp #charPilcrowSign
    beq !newLine+
    jmp !loop-
!loopEnd:

    jmp !return+

!newLine:
    sty tmpY

    lda destinationAddr                     // decrease destination address by current y value
    sec
    sbc currentLineLength
    sta destinationAddr
    lda destinationAddr+1
    sbc #0
    sta destinationAddr+1

    lda destinationAddr                     // increase destination address to new line
    clc
    adc #editorWidth
    sta destinationAddr
    lda destinationAddr+1
    adc #0
    sta destinationAddr+1

    ldx readLinesCounter                    // store line length
    lda currentLineLength
    sta lineLengthCache,x

    inc readLinesCounter

    lda #0
    sta currentLineLength

    jmp !loop-

!return:
    ldx readLinesCounter                    // store last line length
    lda currentLineLength
    sta lineLengthCache,x
    rts

// ========================================

filename: .text @"Filename:\$00"

askFilename:
    jsr invertColors
    jsr clearStatLine

    lda #5                                  // print question
    sta curPosX
    lda #editorStatLineIndex
    sta curPosY
    
    ldx #<filename
    ldy #>filename
    jsr printString

    lda #15
    sta curPosX
    jsr getString
!return:
    jsr invertColors
    rts

// ========================================

xxxLinesWritten: .text @"[XXX lines written]\$00"

printXxxLinesWritten:
    jsr invertColors
    jsr clearStatLine

    lda #5                                  // print sentence
    sta curPosX
    lda #editorStatLineIndex
    sta curPosY
    
    ldx #<xxxLinesWritten
    ldy #>xxxLinesWritten
    jsr printString

    lda saveLinesCounter
    jsr print8

    ldx #6
!number:
    lda num8Digits+0
    sta editorStartStatLine+0,x
    lda num8Digits+1
    sta editorStartStatLine+1,x
    lda num8Digits+2
    sta editorStartStatLine+2,x

!return:
    jsr invertColors
    rts

// ========================================

xxxLinesRead: .text @"[XXX lines read]\$00"

printXxxLinesRead:
    jsr invertColors
    jsr clearStatLine

    lda #5                                  // print sentence
    sta curPosX
    lda #editorStatLineIndex
    sta curPosY
    
    ldx #<xxxLinesRead
    ldy #>xxxLinesRead
    jsr printString

    lda readLinesCounter
    jsr print8

    ldx #6
!number:
    lda num8Digits+0
    sta editorStartStatLine+0,x
    lda num8Digits+1
    sta editorStartStatLine+1,x
    lda num8Digits+2
    sta editorStartStatLine+2,x

!return:
    jsr invertColors
    rts

// ========================================

clearStatLine:
    pha

    lda #charSpace
    ldx #0

!loop:
    sta editorStartStatLine,x
    inx
    cpx #screenWidth
    beq !return+
    jmp !loop-

!return:
    pla
    rts

// ========================================

showEditMarker:
    jsr invertColors
    lda #charAsterisk
    ldx #14
    sta screenMemStart,x
    jsr invertColors
!return:
    rts

// ========================================

clearEditMarker:
    jsr invertColors
    lda #charSpace
    ldx #14
    sta screenMemStart,x
    jsr invertColors
!return:
    rts

// ========================================

editorPrintableChar:
    ldx curPosX                             // don't leave screen
    cpx #screenWidth - 1
    beq !return+

    lda currentPrintableChar

!replaceSpace:
    cmp #charSpace
    bne !continue+
    lda #charBulletOperator
!continue:
    jsr printChar
    jsr storeCharInCache
    jsr incrCursor
    inc currentLineCur
    lda currentLineCur
    ldx currentLine
    cmp lineLengthCache,x
    beq !return+
    bcc !return+
    sta lineLengthCache,x

!return:
    rts

// ========================================

editorBackspace:
    ldx curPosX                             // don't leave editor area
    cpx #editorStartX
    beq !return+

    jsr decrCursor
    dec currentLineCur
    ldx currentLine
    dec lineLengthCache,x
    jsr backspaceShiftLeft
    jsr copyLineToCache
!return:
    rts

// ========================================

editorEnter:
    ldx curPosX                             // don't leave screen
    cpx #screenWidth - 1
    beq !return+

    lda #charPilcrowSign                    // print line feed symbol as end of line
    jsr printChar
    jsr storeCharInCache
/*     inc currentLineCur
    lda currentLineCur
    ldx currentLine
    sta lineLengthCache,x */

    lda #editorStartX                       // new line
    sta curPosX
    inc curPosY
    lda #screenHeight - editorFooterHeight
    cmp curPosY
    bne !continue+
    jsr editorScrollUp
    dec curPosY
!continue:
    inc currentLine
    lda #0
    sta currentLineCur
!return:
    rts

// ========================================

editorCursorLeft:

// Affects: X
// Preserves: A, Y

!cursorLeft:
    dec curPosX                             // no advancing of start of line
    ldx curPosX
    cpx #editorStartX-1
    beq !noCursorLeft+
    dec currentLineCur
    jmp !return+
!noCursorLeft:
    inc curPosX
!return:
    rts

// ========================================

editorCursorRight:

// Affects: A, X
// Preserves: Y

!cursorRight:
    ldx currentLine                         // no advancing if end of line
    lda lineLengthCache,x
    cmp currentLineCur
    beq !return+
    inc curPosX
    inc currentLineCur

!return:
    rts

// ========================================

editorCursorUp:

// Affects: A, X
// Preserves: Y

!cursorUp:
    dec curPosY
    dec currentLine
    ldx curPosY
    cpx #editorHeaderHeight - 1
    bne !continue+
!noCursorUp:
    inc curPosY
    inc currentLine
    jmp !return+
!continue:
    jsr verifyCursor
!return:
    rts

// ========================================

editorCursorDown:

// Affects: A, X
// Preserves: Y

!hasCurrentLineFeed:
    lda curPosX
    pha

    ldx currentLine
    lda lineLengthCache,x
    clc
    adc #editorStartX
    sta curPosX
    jsr getCharOnCurPos
    tax
    pla
    sta curPosX
    txa
    cmp #charPilcrowSign
    bne !return+

!cursorDown:
    inc curPosY
    inc currentLine
    ldx curPosY
    cpx #editorHeight + editorHeaderHeight
    bne !continue+
!noCursorDown:
    dec curPosY
    dec currentLine
    jmp !return+
!continue:
    jsr verifyCursor
!return:
    rts

// ========================================

verifyCursor:
    lda currentLineCur                      // if new line is shorter, reset current line cursor to line length
    ldx currentLine
    cmp lineLengthCache,x
    beq !return+
    bcc !return+
    lda lineLengthCache,x
    sta currentLineCur
    clc
    adc #editorStartX
    sta curPosX
!return:
    rts

// ========================================

storeCharInCache:
    pha

    lda #<editorCache
    sta destinationAddr
    lda #>editorCache
    sta destinationAddr+1

    ldx #0
!loop:
    cpx currentLine
    beq !store+
    lda destinationAddr
    clc
    adc #editorWidth
    sta destinationAddr
    lda destinationAddr+1
    adc #0
    sta destinationAddr+1
    inx
    jmp !loop-

!store:
    pla
    ldy currentLineCur
    sta (destinationAddr),y

!return:
    rts

// ========================================

clearLineLengthCache:
    lda #$00
    ldx #0
!loop:
    cpx #255
    beq !return+
    sta lineLengthCache,x
    inx
    jmp !loop-
!return:
    rts

// ========================================

clearEditorCache:
    lda #0
    sta currentLine

!mainLoop:
    lda currentLine
    cmp #editorHeight
    beq !return+
    tax
    lda lineLengthCache,x
    cmp #0
    bne !getLineStart+
    inc currentLine
    jmp !mainLoop-

!getLineStart:
    lda #<editorCache
    sta destinationAddr
    lda #>editorCache
    sta destinationAddr+1

    ldx #0
!loop:
    cpx currentLine
    beq !loopEnd+
    lda destinationAddr
    clc
    adc #editorWidth
    sta destinationAddr
    lda destinationAddr+1
    adc #0
    sta destinationAddr+1
    inx
    jmp !loop-
!loopEnd:

!clearLine:
    ldy #0
    ldx currentLine
!loop:
    tya
    cmp lineLengthCache,x
    beq !loopEnd+
    lda #$00
    sta (destinationAddr),y
    iny
    jmp !loop-
!loopEnd:

!incMainLoop:
    inc currentLine
    jmp !mainLoop-

!mainLoopEnd:

!return:
    rts

// ========================================

printHeader:
    jsr invertColors

!fillHeader:
    lda #charSpace                         // fill headline with whitespace
    ldx #0
!loop:
    cpx #screenWidth
    beq !printHeader+
    sta editorStartHeader,x
    inx
    jmp !loop-

!printHeader:
    ldx #0
!loop:
    lda header,x
    cmp #$00
    beq !return+
    sta editorStartHeader,x
    inx
    jmp !loop-

!return:
    jsr invertColors
    rts

// ========================================

printFooter:
    ldx #0
!loop:
    lda footer1,x
    cmp #'~'
    bne !dontInvertColors+
    txa
    jsr invertColors
    tax
    inx
    jmp !loop-
!dontInvertColors:
    cmp #$00
    beq !return+
    sta editorStartFooter1,x
    lda footer2,x
    sta editorStartFooter2,x
    inx
    jmp !loop-
!return:
    rts

// ========================================

// X: start line number

currentNumberToPrint: .byte $00
maxNumberToPrint: .byte $00

printLineNumbers:
    sta currentNumberToPrint
    clc
    adc #editorHeight
    sta maxNumberToPrint

    lda #0
    sta curPosX
    lda #editorStartY
    sta curPosY

    jsr invertColors

!loop:
    lda currentNumberToPrint
    cmp maxNumberToPrint
    beq !return+
    jsr print8

!copyNumber:
    lda num8Digits+0
    jsr printChar
    inc curPosX
    lda num8Digits+1
    jsr printChar
    inc curPosX
    lda num8Digits+2
    jsr printChar
    inc curPosY
    lda #0
    sta curPosX

    inc currentNumberToPrint

    jmp !loop-

!return:
    jsr invertColors
    rts

// ========================================

editorReturn:
    rts

// ========================================

invertColors:
    ldx foregroundColor                     // invert foreground and background color
    ldy backgroundColor
    sty foregroundColor
    stx backgroundColor
    rts

// ========================================

editorScrollUp:
    // TODO
!return:
    rts

// ========================================

tmpBackspaceShiftLeftIterator: .byte $00
tmpBackspaceShiftLeftMaxIterator: .byte $00
tmpBackspaceShiftLeftChar: .byte $00
// Affects: A
// Preserves: XY

backspaceShiftLeft:
    jsr calcCurPos
    lda #0
    sta tmpBackspaceShiftLeftIterator

    lda #editorWidth
    sec
    sbc currentLineCur
    sta tmpBackspaceShiftLeftMaxIterator

!loop:
    lda tmpBackspaceShiftLeftIterator
    cmp tmpBackspaceShiftLeftMaxIterator
    beq !return+
    lda #1
    clc
    adc tmpBackspaceShiftLeftIterator
    tay
    lda (tmpCursor),y
    sta tmpBackspaceShiftLeftChar
    lda #0
    clc
    adc tmpBackspaceShiftLeftIterator
    tay
    lda tmpBackspaceShiftLeftChar
    sta (tmpCursor),y
    inc tmpBackspaceShiftLeftIterator
    jmp !loop-
!eraseLastChar:

!return:
    rts

// ========================================

copyLineToCache:
!setSourceAddr:
    lda curPosX                             // set source address to start of line in screen mem
    pha
    lda #editorStartX
    sta curPosX 
    jsr calcCurPos
    lda tmpCursor
    sta sourceAddr
    lda tmpCursor+1
    sta sourceAddr+1
    pla
    sta curPosX
!setDestAddr:
    lda #<editorCache                       // set destination address to start of line in editor cache
    sta destinationAddr
    lda #>editorCache
    sta destinationAddr+1
    ldx #0
!loop:
    cpx currentLine
    beq !copy+
    lda destinationAddr
    clc
    adc #editorWidth
    sta destinationAddr
    lda destinationAddr+1
    adc #0
    sta destinationAddr+1
    inx
    jmp !loop-

!copy:
    ldy #0
!loop:
    cpy #editorWidth
    beq !return+
    lda (sourceAddr),y
    sta (destinationAddr),y
    iny
    jmp !loop-

!return:
    rts

// ========================================

copyEditorCacheToLine:
!setSourceAddr:
    lda #<editorCache                       // set source address to start of line in editor cache
    sta sourceAddr
    lda #>editorCache
    sta sourceAddr+1

    ldx #0
!loop:
    cpx currentLine
    beq !loopEnd+
    lda sourceAddr
    clc
    adc #editorWidth
    sta sourceAddr
    lda sourceAddr+1
    adc #0
    sta sourceAddr+1
    inx
    jmp !loop-
!loopEnd:

!setDestAddr:
    lda curPosX                             // set destination address to start of line in screen mem
    pha
    lda curPosY
    pha
    lda #editorStartX
    sta curPosX 
    lda #editorStartY
    sta curPosY

    ldx #0
!loop:
    cpx currentLine
    beq !loopEnd+
    inc curPosY
    inx
    jmp !loop-
!loopEnd:

    jsr calcCurPos
    lda tmpCursor
    sta destinationAddr
    lda tmpCursor+1
    sta destinationAddr+1
    pla
    sta curPosY
    pla
    sta curPosX

!copy:
    ldx currentLine                         // copy editor cache to line
    ldy #0
!loop:
    tya
    cmp lineLengthCache,x
    beq !return+
    lda (sourceAddr),y
    sta (destinationAddr),y
    iny
    jmp !loop-

!return:
    rts

// ========================================