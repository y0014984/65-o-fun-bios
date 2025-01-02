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

    jsr clearLineLengthCache
    jsr clearEditorCache

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
    jmp !printableChar+

!ctrlX:
    jmp editorReturn

test: .byte $40

!ctrlO:
    jsr commandCtrlO
    jmp !editorLoop-

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
    jsr copyLineToReadWriteBuffer
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
                    
    lda #<editorStartHeader+editorFilenameOffset    // copy header+editorFilenameOffset to destination address
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

copyLineToReadWriteBuffer:
    jsr clearReadWriteBuffer

    ldx saveLinesCounter
    lda lineLengthCache,x
    sta tmpReadWriteBuffer

    lda #<editorCache
    sta sourceAddr
    lda #>editorCache + 1
    sta sourceAddr + 1

    ldx #0
!loop:
    cpx saveLinesCounter
    beq !endLoop+
    lda sourceAddr
    clc
    adc #editorWidth
    sta sourceAddr
    lda sourceAddr+1
    adc #0
    sta sourceAddr+1
    inx
    jmp !loop-
!endLoop:
                    
    lda #<tmpReadWriteBuffer+1              // copy R/W buffer to destination address + 1
    sta destinationAddr
    lda #>tmpReadWriteBuffer+1
    sta destinationAddr + 1

    ldy #0                                  // copy line to buffer
!loop:
    cpy tmpReadWriteBuffer                  // tmpReadWriteBuffer now stores the line length
    beq !loopEnd+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-
!loopEnd:

!return:
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
    inc currentLineCur
    lda currentLineCur
    ldx currentLine
    sta lineLengthCache,x

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
    lda #0
    ldx #0
!loop:
    sta lineLengthCache,x
    inx
    cmp #0
    beq !return+
    jmp !loop-
!return:
    rts

// ========================================

clearEditorCache:
    // TODO
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