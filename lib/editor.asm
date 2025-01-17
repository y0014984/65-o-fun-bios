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

/*
Vertical    (30)
----------------
Header       (1)
vGap         (1)
Editor      (25)
StatusLine   (1)
Footer1      (1)
Footer2      (1)

Horizontal  (40)
----------------
LineNumbers  (3)
hGap         (1)
Editor      (36)
*/

// ========================================
// CONSTANTS
// ========================================

// vertical elements sizes
.const headerWidth          = screenWidth
.const headerHeight         = 1

.const vGapWidth            = screenWidth
.const vGapHeight           = 1

.const statusLineWidth      = screenWidth
.const statusLineHeight     = 1

.const footer1Width         = screenWidth
.const footer1Height        = 1

.const footer2Width         = screenWidth
.const footer2Height        = 1

// horizontal elements sizes
.const lineNumbersWidth     = 3
.const lineNumbersHeight    = screenHeight-headerHeight-vGapHeight-statusLineHeight-footer1Height-footer2Height

.const hGapWidth            = 1
.const hGapHeight           = lineNumbersHeight

.const editorHeight         = lineNumbersHeight
.const editorWidth          = screenWidth-lineNumbersWidth-hGapWidth

// screen mem positions
.const startHeader          = screenMemStart
.const startLineNumbers     = startHeader+(headerWidth*headerHeight)+(vGapWidth*vGapHeight)
.const startEditor          = startLineNumbers+lineNumbersWidth+hGapWidth
.const startStatusLine      = startLineNumbers+((lineNumbersWidth+hGapWidth+editorWidth)*lineNumbersHeight)
.const startFooter1         = startStatusLine+(statusLineWidth*statusLineHeight)
.const startFooter2         = startFooter1+(footer1Width*footer1Height)

// cur positions
.const lineNumbersStartX    = 0
.const lineNumbersStartY    = headerHeight+vGapHeight
.const editorStartX         = lineNumbersWidth+hGapWidth
.const editorStartY         = lineNumbersStartY
.const statusLineX          = 0
.const statusLineY          = headerHeight+vGapHeight+lineNumbersHeight

// Offsets
.const editMarkerOffset     = 14
.const filenameOffset       = 15
.const questionOffset       = 5
.const errorOffset          = 5
.const infoOffset           = 5

// ========================================

.label editorCache          = $08B0         // ends at biosStart
.label editorCacheCursor    = $F6           // Word/2 Bytes

// ========================================
// VARIABLES
// ========================================

currentPrintableChar: .byte $00

// ========================================

editorStart:
    jsr initEditorVariables

    lda #$00
    jsr terminal.fillScreen

    jsr printHeader
    jsr printFooter

    jsr clearEditorCache

    lda #0
    jsr printLineNumbers

    jsr resetEditorCursor

    jmp !printCursor+

!editorLoop:
    jsr getCharFromBuf
    sta currentPrintableChar

    cmp #$00                                // no input
    beq !editorLoop-

    cmp #ctrlBackspace
    beq !backspaceJump+

    cmp #ctrlLineFeed
    beq !enterJump+

    cmp #ctrlArrowLeft
    beq !arrowLeftJump+

    cmp #ctrlArrowRight
    beq !arrowRightJump+

    cmp #ctrlArrowUp
    beq !arrowUpJump+

    cmp #ctrlArrowDown
    beq !arrowDownJump+

    jmp !checkShortcuts+

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

!checkShortcuts:
    ldx ctrlPressed                         // check for special commands
    cpx #TRUE
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

!ctrlR:
    jsr commandCtrlR
    jmp !printCursor+

!ctrlO:
    jsr commandCtrlO
    jmp !editorLoop-

!printCursor:
    lda #charFullBlock
    jsr terminal.printChar
    jmp !editorLoop-

!printableChar:
    lda terminal.cursorChar
    jsr terminal.printChar
    jsr editorPrintableChar
    jsr terminal.getCharOnCurPos
    sta terminal.cursorChar
    jsr showEditMarker
    jmp !printCursor-
!backspace:
    lda terminal.cursorChar
    jsr terminal.printChar
    jsr editorBackspace
    jsr terminal.getCharOnCurPos
    sta terminal.cursorChar
    jsr showEditMarker
    jmp !printCursor-
!enter:
    lda terminal.cursorChar
    jsr terminal.printChar
    jsr editorEnter
    jsr terminal.getCharOnCurPos
    sta terminal.cursorChar
    jsr showEditMarker
    jmp !printCursor-
!arrowLeft:
    lda terminal.cursorChar
    jsr terminal.printChar
    jsr editorCursorLeft
    jsr terminal.getCharOnCurPos
    sta terminal.cursorChar
    jmp !printCursor-
!arrowRight:
    lda terminal.cursorChar
    jsr terminal.printChar
    jsr editorCursorRight
    jsr terminal.getCharOnCurPos
    sta terminal.cursorChar
    jmp !printCursor-
!arrowUp:
    lda terminal.cursorChar
    jsr terminal.printChar
    jsr editorCursorUp
    jsr terminal.getCharOnCurPos
    sta terminal.cursorChar
    jmp !printCursor-
!arrowDown:
    lda terminal.cursorChar
    jsr terminal.printChar
    jsr editorCursorDown
    jsr terminal.getCharOnCurPos
    sta terminal.cursorChar
    jmp !printCursor-

// ========================================

initEditorVariables:
    jsr resetEditorCacheCursor

    lda #$00
    sta terminal.cursorChar
!return:
    rts

// ========================================

saveLinesCounter: .byte $00

commandCtrlO:
    lda terminal.curPosX
    pha
    lda terminal.curPosY
    pha
    lda editorCacheCursor
    pha 
    lda editorCacheCursor+1
    pha

    jsr askFilename
    lda terminal.inpBufLen
    cmp #0
    beq !noFilename+

    jsr copyFilenameToCommandBuffer
    jsr existsFilesystemObject
    cmp #TRUE
    beq !fsObjectExists+
    jmp !saveNewFile+

!fsObjectExists:
    jsr copyFilenameToCommandBuffer
    jsr isFile
    cmp #TRUE
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
    cmp #TRUE
    bne !printError-

    lda #0
    sta saveLinesCounter
    jsr resetEditorCacheCursor
!loop:
    jsr copyFilenameToCommandBuffer
    jsr copyEditorCacheToReadWriteBuffer
    jsr appendFileContent
    cmp #TRUE
    bne !printError-
    ldy #0
    lda (editorCacheCursor),y
    cmp #$00
    beq !finished+
    jmp !loop-

!finished:
    jsr updateFilename
    inc saveLinesCounter                    // increment read lines counter for last line (partially)
    jsr printXxxLinesWritten
    jsr clearEditMarker

!noFilename:
!return:
    pla
    sta editorCacheCursor+1
    pla
    sta editorCacheCursor
    pla
    sta terminal.curPosY
    pla
    sta terminal.curPosX
    rts

// ========================================

readLinesCounter: .byte $00

commandCtrlR:
    lda #0
    sta readLinesCounter

    jsr askFilename
    lda terminal.inpBufLen
    cmp #0
    beq !noFilename+

    jsr copyFilenameToCommandBuffer
    jsr existsFilesystemObject
    cmp #TRUE
    beq !fsObjectExists+
    jmp !noFilesystemObject+

!fsObjectExists:
    jsr copyFilenameToCommandBuffer
    jsr isFile
    cmp #TRUE
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

!fileExists:
    jsr clearEditorCache
    jsr resetEditorCacheCursor
!loop:
    jsr copyFilenameToCommandBuffer
    jsr readFileContent
    jsr copyReadWriteBufferToEditorCache

    lda readWriteBuffer
    cmp #TRUE
    beq !fillScreen+
    cmp #FALSE
    beq !printError-
    jmp !loop-                              // otherwise status is $80 which means not end of file

!fillScreen:
    jsr copyEditorCacheToScreenMem

!finished:
    jsr updateFilename
    inc readLinesCounter                    // increment read lines counter for last line (partially)
    jsr printXxxLinesRead
    jsr clearEditMarker

!noFilename:
!return:
    jsr resetEditorCursor
    jsr resetEditorCacheCursor

    lda startEditor
    sta terminal.cursorChar

    rts

// ========================================

editorPrintError:
    jsr invertColors
    jsr clearStatLine

    ldx #errorOffset
    stx terminal.curPosX
    ldy #statusLineY
    sty terminal.curPosY

    cmp #errCodeFileExists
    beq !errFileExists+
    cmp #errCodeIsDir
    beq !errIsDir+

    jmp !errorUnknown+

!errFileExists:
    ldx #<terminal.errFileExists
    ldy #>terminal.errFileExists
    jmp !printError+

!errIsDir:
    ldx #<terminal.errIsDir
    ldy #>terminal.errIsDir
    jmp !printError+

!errorUnknown:
    ldx #<terminal.errorUnknown
    ldy #>terminal.errorUnknown

!printError:
    jsr terminal.printString

!return:
    jsr invertColors
    rts

// ========================================

copyFilenameToCommandBuffer:
    lda #filenameOffset
    sta terminal.curPosX
    jsr terminal.calcCurPos
    lda terminal.cursor
    sta sourceAddr
    lda terminal.cursor + 1
    sta sourceAddr + 1
                    
    lda #<commandBuffer+3                   // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>commandBuffer+3
    sta destinationAddr + 1

    ldy #0                                  // copy filename to buffer
!loop:
    cpy terminal.inpBufLen
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
    cpx #screenWidth-filenameOffset
    beq !loopEnd+
    sta startHeader+filenameOffset,x
    inx
    jmp !loop-
!loopEnd:

    lda #filenameOffset
    sta terminal.curPosX
    lda #statusLineY
    sta terminal.curPosY
    jsr terminal.calcCurPos
    lda terminal.cursor                     // copy statusLine+filenameOffset to source address
    sta sourceAddr
    lda terminal.cursor + 1
    sta sourceAddr + 1
                                            
    lda #<startHeader+filenameOffset        // copy header+filenameOffset to destination address
    sta destinationAddr
    lda #>startHeader+filenameOffset
    sta destinationAddr + 1

    ldy #0                                  // copy filename to header
!loop:
    cpy terminal.inpBufLen
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

    lda editorCacheCursor                   // copy editor cache cursor to source address
    sta sourceAddr
    lda editorCacheCursor+1
    sta sourceAddr+1
                    
    lda #<readWriteBuffer+1                 // copy R/W buffer to destination address + 1
    sta destinationAddr
    lda #>readWriteBuffer+1
    sta destinationAddr+1

    ldy #0                                  // copy editor cache to buffer
!loop:
    cpy #readWriteBufferLength-1
    beq !return+
    lda (sourceAddr),Y
    cmp #ctrlLineFeed
    beq !incrSaveLinesCounter+
    cmp #$00
    beq !return+
!continue:
    sta (destinationAddr),y
    iny
    lda #<editorCacheCursor
    jsr incrZeropageAddr
    jmp !loop-

!incrSaveLinesCounter:
    inc saveLinesCounter
    jmp !continue-

!return:
    sty readWriteBuffer                     // store written bytes count
    rts

// ========================================

copyReadWriteBufferToEditorCache:
    lda #<readWriteBuffer+2                 // copy R/W buffer + 2 to source address
    sta sourceAddr
    lda #>readWriteBuffer+2
    sta sourceAddr+1

    lda editorCacheCursor                   // copy editor cache cursor to destination address
    sta destinationAddr
    lda editorCacheCursor+1
    sta destinationAddr+1

    ldy #0                                  // copy buffer to line
!loop:
    cpy readWriteBuffer+1                   // readWriteBuffer + 1 stores the line length
    beq !return+
    lda (sourceAddr),y
    cmp #ctrlLineFeed
    beq !incrReadLinesCounter+
!continue:
    sta (destinationAddr),y
    iny
    lda #<editorCacheCursor
    jsr incrZeropageAddr
    jmp !loop-

!incrReadLinesCounter:
    inc readLinesCounter
    jmp !continue-

!return:
    rts

// ========================================

filename: .text @"Filename:\$00"

askFilename:
    jsr invertColors
    jsr clearStatLine

    lda #questionOffset                     // print question
    sta terminal.curPosX
    lda #statusLineY
    sta terminal.curPosY
    
    ldx #<filename
    ldy #>filename
    jsr terminal.printString

    lda #filenameOffset                     // get answer
    sta terminal.curPosX
    jsr terminal.getString
!return:
    jsr invertColors
    rts

// ========================================

xxxLinesWritten: .text @"[XXX lines written]\$00"
.const linesWrittenNumberOffset = 1

printXxxLinesWritten:
    jsr invertColors
    jsr clearStatLine

    lda #infoOffset                         // print sentence
    sta terminal.curPosX
    lda #statusLineY
    sta terminal.curPosY
    
    ldx #<xxxLinesWritten
    ldy #>xxxLinesWritten
    jsr terminal.printString

    lda saveLinesCounter
    jsr print8

    ldx #infoOffset+linesWrittenNumberOffset
!number:
    lda num8Digits+0
    sta startStatusLine+0,x
    lda num8Digits+1
    sta startStatusLine+1,x
    lda num8Digits+2
    sta startStatusLine+2,x

!return:
    jsr invertColors
    rts

// ========================================

xxxLinesRead: .text @"[XXX lines read]\$00"
.const linesReadNumberOffset = 1

printXxxLinesRead:
    jsr invertColors
    jsr clearStatLine

    lda #infoOffset                         // print sentence
    sta terminal.curPosX
    lda #statusLineY
    sta terminal.curPosY
    
    ldx #<xxxLinesRead
    ldy #>xxxLinesRead
    jsr terminal.printString

    lda readLinesCounter
    jsr print8

    ldx #infoOffset+linesReadNumberOffset
!number:
    lda num8Digits+0
    sta startStatusLine+0,x
    lda num8Digits+1
    sta startStatusLine+1,x
    lda num8Digits+2
    sta startStatusLine+2,x

!return:
    jsr invertColors
    rts

// ========================================

clearStatLine:
    pha

    lda #charSpace
    ldx #0

!loop:
    sta startStatusLine,x
    inx
    cpx #statusLineWidth
    beq !return+
    jmp !loop-

!return:
    pla
    rts

// ========================================

isEditMarkerVisible: .byte FALSE

showEditMarker:
    lda isEditMarkerVisible
    cmp #TRUE
    beq !return+

    jsr invertColors
    lda #charAsterisk
    ldx #editMarkerOffset
    sta startHeader,x
    jsr invertColors
    lda #TRUE
    sta isEditMarkerVisible
!return:
    rts

// ========================================

clearEditMarker:
    lda isEditMarkerVisible
    cmp #FALSE
    beq !return+

    jsr invertColors
    lda #charSpace
    ldx #editMarkerOffset
    sta startHeader,x
    jsr invertColors
    lda #FALSE
    sta isEditMarkerVisible
!return:
    rts

// ========================================

editorPrintableChar:
    ldx terminal.curPosX                    // don't leave screen
    cpx #screenWidth - 2
    beq !return+

!replaceSpace:
    lda currentPrintableChar
    cmp #charSpace
    bne !shiftRightScreenMem+
    lda #charBulletOperator
    sta currentPrintableChar

!shiftRightScreenMem:
    jsr shiftRightScreenMem

!replaceBulletOperator:
    lda currentPrintableChar
    cmp #charBulletOperator
    bne !shiftRightEditorCache+
    lda #charSpace
    sta currentPrintableChar

!shiftRightEditorCache:
    jsr shiftRightEditorCache

!incrCursors:
    jsr terminal.incrCursor
    lda #<editorCacheCursor
    jsr incrZeropageAddr

!return:
    rts

// ========================================

editorBackspace:
    ldx terminal.curPosX                    // don't leave editor area
    cpx #editorStartX
    beq !return+

!decreaseCursors:
    jsr terminal.decrCursor
    lda #<editorCacheCursor
    jsr decrZeropageAddr

!shiftLeft:
    jsr shiftLeftScreenMem
    jsr shiftLeftEditorCache

!return:
    rts

// ========================================

// TODO: handle scrolling at the end of editor

editorEnter:
    ldx terminal.curPosX                    // don't leave screen
    cpx #screenWidth - 1
    beq !return+

    ldx terminal.curPosY                    // don't leave editor
    cpx #screenHeight - footer1Height - footer2Height - vGapHeight - 1
    beq !return+

    jsr terminal.calcCurPos                 // allow only at end of line
    ldy #0
    lda (terminal.cursor),y
    cmp #$00
    bne !return+

    lda #charPilcrowSign                    // print line feed symbol in screen ram
    sta (terminal.cursor),y
    lda #ctrlLineFeed                       // store line feed in editor cache
    sta (editorCacheCursor),y

!newLine:
    lda #editorStartX                       // new line
    sta terminal.curPosX
    inc terminal.curPosY
    lda #<editorCacheCursor                 // increment editor cache cursor
    jsr incrZeropageAddr

!return:
    rts

// ========================================

editorCursorLeft:

// Affects: A, X
// Preserves: Y

!cursorLeft:
    ldx terminal.curPosX
    cpx #editorStartX                       // don't go beyond editor start
    beq !return+

    dec terminal.curPosX
    lda #<editorCacheCursor
    jsr decrZeropageAddr

    // TODO: if start of line reached goto previous line

!return:
    rts

// ========================================

editorCursorRight:

// Affects: A, Y
// Preserves: X

!cursorRight:
    jsr terminal.calcCurPos
    ldy #0
    lda (terminal.cursor),y                 // get char under current cursor
    cmp #$00
    beq !return+                            // if end of editor cache reached
    cmp #charPilcrowSign
    beq !return+                            // if end of line reached

    inc terminal.curPosX
    lda #<editorCacheCursor
    jsr incrZeropageAddr

    // TODO: if end of line reached goto next line

!return:
    rts

// ========================================

editorCursorUp:

// Affects: A, X
// Preserves: Y

!checkTopLimit:
    lda terminal.curPosY
    cmp #headerHeight + vGapHeight
    beq !return+

!cursorUp:
    dec terminal.curPosY
    jsr editorCacheEndOfPreviousLine
    jsr verifyCursor                        // Y contains offset
    lda #<editorCacheCursor
!loop:
    cpy #0
    beq !return+
    jsr decrZeropageAddr                    // move editor cache cursor
    dey                                     // to offeset in line
    jmp !loop-
!return:
    rts

// ========================================

editorCacheEndOfPreviousLine:
    ldy #0
    lda #<editorCacheCursor
    jsr decrZeropageAddr
!loop:
    lda (editorCacheCursor),y               // move editor cache cursor 
    cmp #ctrlLineFeed                       // to previous line feed
    beq !return+
    lda #<editorCacheCursor
    jsr decrZeropageAddr
    jmp !loop-

!return:
    rts

// ========================================

editorCursorDown:

// Affects: A, X
// Preserves: Y

!checkBottomLimit:
    lda terminal.curPosY
    cmp #headerHeight + vGapHeight + editorHeight - 1
    beq !return+

!checkLastLine:
    jsr terminal.calcCurPos
    ldy #0
!loop:
    lda (terminal.cursor),y
    cmp #$00
    beq !return+
    cmp #charPilcrowSign
    beq !loopEnd+
    beq !return+
    lda #<terminal.cursor
    jsr incrZeropageAddr
    jmp !loop-
!loopEnd:

!cursorDown:
    inc terminal.curPosY
    jsr editorCacheEndOfNextLine
    jsr verifyCursor                        // Y contains offset
    lda #<editorCacheCursor
!loop:
    cpy #0
    beq !return+
    jsr decrZeropageAddr                    // move editor cache cursor
    dey                                     // to offeset in line
    jmp !loop-
!return:
    rts

// ========================================

nextLineReached: .byte $00

editorCacheEndOfNextLine:
    lda #FALSE
    sta nextLineReached
!loop:
    ldy #0
    lda (editorCacheCursor),y
    cmp #ctrlLineFeed                       // end of line reached
    beq !currentLine+
    cmp #$00                                // end of cache reached
    beq !return+
    lda #<editorCacheCursor
    jsr incrZeropageAddr
    jmp !loop-

!currentLine:
    lda nextLineReached
    cmp #TRUE
    beq !return+

!nextLine:
    lda #<editorCacheCursor
    jsr incrZeropageAddr
    lda #TRUE
    sta nextLineReached
    jmp !loop-

!return:
    rts

// ========================================

// Sets Cursor to End of Line or
// returns horizontal Offset to Line End in Y

verifyCursor:
    jsr terminal.calcCurPos

    ldy #0
    lda (terminal.cursor),y
    cmp #$00                                // in empty space right of line end
    beq !moveLeftToLineEnd+
    cmp #charPilcrowSign                    // directly on line end
    beq !return+
    jmp !calcLineEndOffset+                 // in mid-line

!moveLeftToLineEnd:

!loop:
    dec terminal.curPosX
    jsr terminal.calcCurPos
    lda terminal.curPosX
    cmp #lineNumbersWidth + hGapWidth       // is next line an empty last line?
    beq !return+
    ldy #0
    lda (terminal.cursor),y
    cmp #$00                                // in empty space right of line end
    beq !loop-
    cmp #charPilcrowSign                    // directly on line end
    beq !return+
    inc terminal.curPosX                    // last line element
    jmp !return+

!calcLineEndOffset:
    ldy #0
!loop:
    lda (terminal.cursor),y
    cmp #$00
    beq !return+
    cmp #charPilcrowSign
    beq !return+
    iny
    jmp !loop-

!return:
    rts

// ========================================

clearEditorCache:
    jsr resetEditorCacheCursor

    ldy #0
!loop:
    lda editorCacheCursor
    cmp #<biosStart
    beq !isEndReached+
    jmp !continue+
!isEndReached:
    lda editorCacheCursor+1
    cmp #>biosStart
    beq !return+
!continue:
    lda (editorCacheCursor),y
    cmp #$00
    beq !return+                            // stop when cache wasn't used before
    lda #$00
    sta (editorCacheCursor),y               // clear editor cache with $00
    lda #<editorCacheCursor
    jsr incrZeropageAddr
    jmp !loop-

!return:
    jsr resetEditorCacheCursor
    rts

// ========================================

resetEditorCacheCursor:
    lda #<editorCache
    sta editorCacheCursor
    lda #>editorCache
    sta editorCacheCursor+1
!return:
    rts

// ========================================

resetEditorCursor:
    lda #editorStartX
    sta terminal.curPosX
    lda #editorStartY
    sta terminal.curPosY
!return:
    rts

// ========================================

printHeader:
    jsr invertColors

!fillHeader:
    lda #charSpace                         // fill header with whitespace
    ldx #0
!loop:
    cpx #headerWidth
    beq !printHeader+
    sta startHeader,x
    inx
    jmp !loop-

!printHeader:
    ldx #0
!loop:
    lda header,x
    cmp #$00
    beq !return+
    sta startHeader,x
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
    sta startFooter1,x 
    lda footer2,x                           // footer 1 & 2 are aligned
    sta startFooter2,x                      // that's why no check for '~' happens
    inx
    jmp !loop-
!return:
    rts

// ========================================

// Params:
//   A: start line number

currentNumberToPrint: .byte $00

printLineNumbers:
    clc
    adc #1                                  // line numbers start at 1 and not 0
    sta currentNumberToPrint

    ldx #lineNumbersStartX
    stx terminal.curPosX
    ldy #lineNumbersStartY
    sty terminal.curPosY

    jsr invertColors

!loop:
    lda currentNumberToPrint
    cmp #lineNumbersHeight+1
    beq !return+
    jsr print8

!copyNumber:
    lda num8Digits+0
    jsr terminal.printChar
    inc terminal.curPosX
    lda num8Digits+1
    jsr terminal.printChar
    inc terminal.curPosX
    lda num8Digits+2
    jsr terminal.printChar
    inc terminal.curPosY
    lda #lineNumbersStartX
    sta terminal.curPosX

    inc currentNumberToPrint

    jmp !loop-

!return:
    jsr invertColors
    rts

// ========================================

editorReturn:
    rts

// ========================================

isColorInverted: .byte FALSE

invertColors:                               // invert first two colors by switching color palette
    ldx isColorInverted
    cpx #TRUE
    beq !isTrue+
!isFalse:
    ldx #<terminal.colorTable2
    stx colorTableAddr
    ldx #>terminal.colorTable2
    stx colorTableAddr+1
    ldx #TRUE
    stx isColorInverted
    jmp !return+
!isTrue:
    ldx #<terminal.colorTable1
    stx colorTableAddr
    ldx #>terminal.colorTable1
    stx colorTableAddr+1
    ldx #FALSE
    stx isColorInverted

!return:
    rts

// ========================================

editorScrollUp:
    // TODO
!return:
    rts

// ========================================

shiftLeftScreenMem:
    lda terminal.curPosX
    pha
    lda terminal.curPosY
    pha

!loop:
    jsr terminal.calcCurPos

    ldy #1
    lda (terminal.cursor),y
    cmp #$00                                // end of editor cache reached?
    beq !clearLastChar+

    ldy #0
    sta (terminal.cursor),y                 // shift left in screen mem

    jsr terminal.incrCursor
    jmp !loop-

!clearLastChar:
    ldy #0
    lda #$00
    sta (terminal.cursor),y

!return:
    pla
    sta terminal.curPosY
    pla
    sta terminal.curPosX
    rts

// ========================================

shiftLeftEditorCache:
    lda editorCacheCursor
    pha
    lda editorCacheCursor+1
    pha

!loop:

    ldy #1
    lda (editorCacheCursor),y
    cmp #$00                                // end of editor cache reached?
    beq !clearLastChar+

    ldy #0
    sta (editorCacheCursor),y               // shift left in editor cache
    lda #<editorCacheCursor
    jsr incrZeropageAddr
    jmp !loop-

!clearLastChar:
    ldy #0
    lda #$00
    sta (editorCacheCursor),y

!return:
    pla
    sta editorCacheCursor+1
    pla 
    sta editorCacheCursor
    rts

// ========================================

newChar: .byte $00
nextChar: .byte $00

// TODO: shifts beyond end of line if cursor is mid-line

shiftRightScreenMem:
    sta newChar

    lda terminal.curPosX
    pha
    lda terminal.curPosY
    pha

!loop:
    jsr terminal.calcCurPos
    lda newChar
    cmp #$00                                // end of editor cache reached?
    beq !storeLastChar+

!fourStepsShift:
    ldy #1
    lda (terminal.cursor),y
    sta nextChar                            // store next char in nextChar

    ldy #0
    lda (terminal.cursor),y                 // get char under cursor

    ldy #1
    sta (terminal.cursor),y                 // shift right in screen mem

    lda newChar
    ldy #0
    sta (terminal.cursor),y                 // store newChar in screen ram

    lda nextChar
    sta newChar                             // copy nextChar to newChar

!incrementCursors:                          // two times
    jsr terminal.incrCursor
    jsr terminal.incrCursor
    jmp !loop-

!storeLastChar:
    ldy #0
    lda newChar
    sta (terminal.cursor),y

!return:
    pla
    sta terminal.curPosY
    pla
    sta terminal.curPosX
    rts

// ========================================

shiftRightEditorCache:
    sta newChar

    lda editorCacheCursor
    pha
    lda editorCacheCursor+1
    pha

!loop:
    lda newChar
    cmp #$00                                // end of editor cache reached?
    beq !storeLastChar+

!fourStepsShift:
    ldy #1
    lda (editorCacheCursor),y
    sta nextChar                            // store next char in nextChar

    ldy #0
    lda (editorCacheCursor),y               // get char under cursor

    ldy #1
    sta (editorCacheCursor),y               // shift right in editor cache

    lda newChar
    ldy #0
    sta (editorCacheCursor),y               // store newChar in editor cache

    lda nextChar
    sta newChar                             // copy nextChar to newChar

!incrementCursors:                          // two times
    lda #<editorCacheCursor
    jsr incrZeropageAddr
    jsr incrZeropageAddr
    jmp !loop-

!storeLastChar:
    ldy #0
    lda newChar
    sta (editorCacheCursor),y

!return:
    pla
    sta editorCacheCursor+1
    pla 
    sta editorCacheCursor
    rts

// ========================================

insertLineFeedCounter: .byte $00

copyEditorCacheToScreenMem:
    lda #0
    sta insertLineFeedCounter

!setSourceAddr:
    lda #<editorCache                       // set source address to start of editor cache
    sta sourceAddr
    lda #>editorCache
    sta sourceAddr+1

!setDestAddr:
    lda #<startEditor                       // set destination address to start of editor screen mem
    sta destinationAddr
    lda #>startEditor
    sta destinationAddr+1

!copy:
    ldy #0
!loop:
    lda (sourceAddr),y
    cmp #$00
    beq !return+
    cmp #ctrlLineFeed
    beq !lineFeed+
    cmp #charSpace
    beq !space+
    sta (destinationAddr),y
    lda #<destinationAddr
    jsr incrZeropageAddr
!continue:
    lda #<sourceAddr
    jsr incrZeropageAddr
    jmp !loop-

!lineFeed:
    lda #charPilcrowSign
    sta (destinationAddr),y

    inc insertLineFeedCounter

    jsr resetEditorCursor
    lda terminal.curPosY
    clc
    adc insertLineFeedCounter
    sta terminal.curPosY
    jsr terminal.calcCurPos

    lda terminal.cursor                     // set destination address to start of next line in screen mem
    sta destinationAddr
    lda terminal.cursor+1
    sta destinationAddr+1

    jmp !continue-

!space:
    lda #charBulletOperator
    sta (destinationAddr),y

    lda #<destinationAddr
    jsr incrZeropageAddr

    jmp !continue-

!return:
    rts

// ========================================