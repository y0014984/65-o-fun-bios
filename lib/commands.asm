// ========================================

#importonce 

#import "../constants.asm"
#import "terminal.asm"
#import "storage.asm"
#import "editor.asm"

// ========================================

paramLength: .byte $00

echoCommand:
    lda inpBufLen                           // INP_BUF_LEN - 6 = length of parameter to print
    cmp #6
    bcc !return+                            // A<6 = no parameter
    sec
    sbc #5
    sta paramLength

    ldx #6                                  // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda cursor
    sta sourceAddr
    lda cursor + 1
    sta sourceAddr + 1
                    
    lda #<terminalOutputBuffer              // copy start of terminal output buffer to destination address
    sta destinationAddr
    lda #>terminalOutputBuffer
    sta destinationAddr + 1

    ldy #0                                  // copy parameter to next line until a $00 is reached
!loop:
    cpy paramLength
    beq !print+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!print:
    ldx #<terminalOutputBuffer
    ldy #>terminalOutputBuffer
    jsr printTerminalLine

!return:
    rts

// ========================================

clearCommand:
    lda #charSpace
    jsr fillScreen
    lda #0
    sta curPosX
    lda #255
    sta curPosY
!return:
    rts

// ========================================

unameString: .text @"65-o-fun v0.1 BIOS\$00"

unameCommand:
    ldx #<unameString
    ldy #>unameString
    jsr printTerminalLine
!return:
    rts

// ========================================

dateString: .text @"Wee Mon DD HH:MM:SS CET YEAR\$00" // template
dayNames: .text "SunMonTueWedThuFriSat"
monthNames: .text "JanFebMarAprMayJunJulAugSepOctNovDec"
dateIndex: .byte $00

dateCommand:
!getWeekday:
    lda dateTimeWeekdayMonth
    and #%11110000
    lsr
    lsr
    lsr
    lsr

!findWeekday:
    ldx #0
    stx dateIndex
!loop:
    cmp dateIndex
    beq !copyWeekday+
    inx
    inx
    inx
    inc dateIndex
    jmp !loop-

!copyWeekday:
    ldy #0
!loop:
    lda dayNames,x
    sta dateString,y
    lda dayNames+1,x
    sta dateString+1,y
    lda dayNames+2,x
    sta dateString+2,y

!getMonth:
    lda dateTimeWeekdayMonth
    and #%00001111

!findMonth:
    ldx #0
    stx dateIndex
!loop:
    cmp dateIndex
    beq !copyMonth+
    inx
    inx
    inx
    inc dateIndex
    jmp !loop-

!copyMonth:
    ldy #4
!loop:
    lda monthNames,x
    sta dateString,y
    lda monthNames+1,x
    sta dateString+1,y
    lda monthNames+2,x
    sta dateString+2,y

!getDay:
    lda dateTimeDay
    jsr print8

    ldx #8
!copyDay:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getHours:
    lda dateTimeHours
    jsr print8

    ldx #11
!copyHours:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getMinutes:
    lda dateTimeMinutes
    jsr print8

    ldx #14
!copyMinutes:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getSeconds:
    lda dateTimeSeconds
    jsr print8

    ldx #17
!copySeconds:
    lda num8Digits+1
    sta dateString+0,x
    lda num8Digits+2
    sta dateString+1,x

!getYear:
    ldx dateTimeYear
    lda dateTimeYear+1
    jsr print16

    ldx #24
!copyYear:
    lda num16Digits+1
    sta dateString+0,x
    lda num16Digits+2
    sta dateString+1,x
    lda num16Digits+3
    sta dateString+2,x
    lda num16Digits+4
    sta dateString+3,x

!print:
    ldx #<dateString
    ldy #>dateString
    jsr printTerminalLine
!return:
    rts

// ========================================

// the output of this command could be precalculated
// with Kick Assembler scripting

helpString: .fill screenWidth, $00

helpCommand:
    ldx #0
    ldy #0
!loop:
    cpy #screenWidth - 1
    beq !print+
    lda commandList,x
    cmp #$00
    beq !addComma+
    sta helpString,y
    inx
    iny
    jmp !loop-

!addComma:
    lda commandList+1,x
    cmp #$00
    beq !printAndReturn+
    lda #charComma
    sta helpString,y
    inx
    iny
    jmp !loop-

!print:
    jsr printHelpString
    jsr clearHelpString
    ldy #0
    jmp !loop-

!printAndReturn:
    jsr printHelpString
    jsr clearHelpString

!return:
    rts

// --------------------

printHelpString:
    txa
    pha
    tya
    pha
    ldx #<helpString
    ldy #>helpString
    jsr printTerminalLine
!return:
    pla
    tay
    pla
    tax
    rts

// --------------------

clearHelpString:
    tya
    ldy #0
!loop:
    lda #$00
    sta helpString,y
    iny
    cpy #screenWidth
    beq !return+
    jmp !loop-
!return:
    tay
    rts

// ========================================

lsHeadlineString: .text @" ID Type  Size Name\$00"
fsObjectCount: .byte $00
fsObjectIndex: .byte $00
fsObjectType: .byte $00
lsString: .fill screenWidth-1, $20
.byte $00

lsCommand:
    ldx #<lsHeadlineString
    ldy #>lsHeadlineString
    jsr printTerminalLine

    jsr getFilesystemObjectCount
    sta fsObjectCount

    lda #0
    sta fsObjectIndex
!loop:
    lda fsObjectIndex
    cmp fsObjectCount
    beq !return+
    jsr print8

    ldx #0
!copyIndex:
    lda num8Digits+0
    sta lsString+0,x
    lda num8Digits+1
    sta lsString+1,x
    lda num8Digits+2
    sta lsString+2,x

    jsr getType

    jsr getSize

    jsr getName

!printLine:
    ldx #<lsString
    ldy #>lsString
    jsr printTerminalLine
    jsr clearLsString
    inc fsObjectIndex
    jmp !loop-

!return:
    rts

// --------------------

getName:
    lda fsObjectIndex
    jsr getFilesystemObjectName

!copyName:
    ldy #0
    ldx #15
!loop:
    lda readWriteBuffer,y
    cmp #$00
    beq !return+
    sta lsString,x
    iny
    inx
    jmp !loop-

!return:
    rts

// --------------------

getSize:
    lda fsObjectType
    cmp #fsoTypeDirectory
    bne !getSize+

!noSize:
    ldx #9
    lda #'-'
    sta lsString+0,x
    lda #'-'
    sta lsString+1,x
    lda #'-'
    sta lsString+2,x
    lda #'-'
    sta lsString+3,x
    lda #'-'
    sta lsString+4,x
    jmp !return+

!getSize:
    lda fsObjectIndex
    jsr getFileSize
    tya
    jsr print16

    ldx #9
!copySize:
    lda num16Digits+0
    sta lsString+0,x
    lda num16Digits+1
    sta lsString+1,x
    lda num16Digits+2
    sta lsString+2,x
    lda num16Digits+3
    sta lsString+3,x
    lda num16Digits+4
    sta lsString+4,x

!return:
    rts

// --------------------

getType:
    lda fsObjectIndex
    jsr getFilesystemObjectType
    txa
    sta fsObjectType
    ldx #5
    cmp #fsoTypeDirectory
    beq !printTypeDirectory+
    cmp #fsoTypeFile
    beq !printTypeFile+
    cmp #fsoTypeProgram
    beq !printTypeProgram+

!printTypeDirectory:
    lda #'D'
    sta lsString+0,x
    lda #'I'
    sta lsString+1,x
    lda #'R'
    sta lsString+2,x
    jmp !return+

!printTypeFile:
    lda #'F'
    sta lsString+0,x
    lda #'I'
    sta lsString+1,x
    lda #'L'
    sta lsString+2,x
    jmp !return+

!printTypeProgram:
    lda #'P'
    sta lsString+0,x
    lda #'R'
    sta lsString+1,x
    lda #'G'
    sta lsString+2,x
    jmp !return+

!return:
    rts

// --------------------

clearLsString:
    ldy #0
!loop:
    lda #$20
    sta lsString,y
    iny
    cpy #screenWidth - 1
    beq !return+
    jmp !loop-
!return:
    rts

// ========================================

cdCommand:
    lda inpBufLen                           // INP_BUF_LEN - 4 = length of parameter to print
    cmp #4
    bcc !return+                            // A<4 = no parameter
    sec
    sbc #3
    sta paramLength

    ldx #4                                  // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda cursor
    sta sourceAddr
    lda cursor + 1
    sta sourceAddr + 1
                    
    lda #<commandBuffer+3                   // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>commandBuffer+3
    sta destinationAddr + 1

    ldy #0                                  // copy parameter to buffer until a $00 is reached
!loop:
    cpy paramLength
    beq !gotoDir+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!gotoDir:
    jsr gotoDirectory
    cmp #TRUE
    beq !return+

!printError:
    lda storageComLastErr
    jsr printError

!return:
    rts

// ========================================

pwdString: .fill screenWidth-1, $20

pwdCommand:
    jsr getWorkingDirectory

!copyPath:
    ldx #0
!loop:
    lda readWriteBuffer,x
    cmp #$00
    beq !printLine+
    sta pwdString,x
    iny
    inx
    jmp !loop-

!printLine:
    ldx #<pwdString
    ldy #>pwdString
    jsr printTerminalLine
    jsr clearPwdString

!return:
    rts

// --------------------

clearPwdString:
    ldy #0
!loop:
    lda #$20
    sta pwdString,y
    iny
    cpy #screenWidth - 1
    beq !return+
    jmp !loop-
!return:
    rts

// ========================================

mkdirCommand:
    lda inpBufLen                           // INP_BUF_LEN - 7 = length of parameter to print
    cmp #7
    bcc !return+                            // A<7 = no parameter
    sec
    sbc #6
    sta paramLength

    ldx #7                                  // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda cursor
    sta sourceAddr
    lda cursor + 1
    sta sourceAddr + 1
                    
    lda #<commandBuffer+3                   // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>commandBuffer+3
    sta destinationAddr + 1

    ldy #0                                  // copy parameter to buffer until a $00 is reached
!loop:
    cpy paramLength
    beq !gotoDir+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!gotoDir:
    jsr createDirectory
    cmp #TRUE
    beq !return+

!printError:
    lda storageComLastErr
    jsr printError

!return:
    rts

// ========================================

rmdirCommand:
    lda inpBufLen                           // INP_BUF_LEN - 7 = length of parameter to print
    cmp #7
    bcc !return+                            // A<7 = no parameter
    sec
    sbc #6
    sta paramLength

    ldx #7                                  // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda cursor
    sta sourceAddr
    lda cursor + 1
    sta sourceAddr + 1
                    
    lda #<commandBuffer+3                   // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>commandBuffer+3
    sta destinationAddr + 1

    ldy #0                                  // copy parameter to buffer until a $00 is reached
!loop:
    cpy paramLength
    beq !gotoDir+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!gotoDir:
    jsr removeDirectory
    cmp #TRUE
    beq !return+

!printError:
    lda storageComLastErr
    jsr printError

!return:
    rts

// ========================================

touchCommand:
    lda inpBufLen                           // INP_BUF_LEN - 7 = length of parameter to print
    cmp #7
    bcc !return+                            // A<7 = no parameter
    sec
    sbc #6
    sta paramLength

    ldx #7                                  // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda cursor
    sta sourceAddr
    lda cursor + 1
    sta sourceAddr + 1
                    
    lda #<commandBuffer+3                   // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>commandBuffer+3
    sta destinationAddr + 1

    ldy #0                                  // copy parameter to buffer until a $00 is reached
!loop:
    cpy paramLength
    beq !gotoDir+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!gotoDir:
    jsr createFile
    cmp #TRUE
    beq !return+

!printError:
    lda storageComLastErr
    jsr printError

!return:
    rts

// ========================================

rmCommand:
    lda inpBufLen                           // INP_BUF_LEN - 4 = length of parameter to print
    cmp #4
    bcc !return+                            // A<4 = no parameter
    sec
    sbc #3
    sta paramLength

    ldx #4                                  // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda cursor
    sta sourceAddr
    lda cursor + 1
    sta sourceAddr + 1
                    
    lda #<commandBuffer+3                   // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>commandBuffer+3
    sta destinationAddr + 1

    ldy #0                                  // copy parameter to buffer until a $00 is reached
!loop:
    cpy paramLength
    beq !gotoDir+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!gotoDir:
    jsr removeFile
    cmp #TRUE
    beq !return+

!printError:
    lda storageComLastErr
    jsr printError

!return:
    rts

// ========================================

bonoCommand:
    jsr editorStart
    jsr initTerminal

!return:
    rts

// ========================================

loadAddress: .word $0000
loadAddressCursor: .word $0000

runCommand:

!loadProgram:
    jsr copyRunCommandParameter
    jsr existsFilesystemObject
    cmp #TRUE
    beq !fsObjectExists+
    jmp !noFilesystemObject+

!fsObjectExists:
    jsr copyRunCommandParameter
    jsr isProgram
    cmp #TRUE
    beq !getLoadAddress+
    jsr printError
    jmp !return+

!noFilesystemObject:
    jsr printError
    jmp !return+

!printError:
    lda storageComLastErr
    jsr printError

!getLoadAddress:
    jsr copyRunCommandParameter
    jsr getLoadAddress
    cmp #TRUE
    beq !programExists+
    lda #errCodeNotProgram
    jsr editorPrintError
    jmp !return+

!programExists:
    lda readWriteBuffer
    sta loadAddress
    sta loadAddressCursor
    lda readWriteBuffer+1
    sta loadAddress+1
    sta loadAddressCursor+1
!loop:
    jsr copyRunCommandParameter
    jsr readFileContent
    jsr copyReadWriteBufferToMemory

    lda readWriteBuffer
    cmp #TRUE
    beq !setLoadAddress+
    cmp #FALSE
    beq !printError-
    jmp !loop-                              // otherwise status is $80 which means not end of file

!setLoadAddress:                            // self modifying code to set load address for jsr
    lda loadAddress
    sta usedLoadAddress+1
    lda loadAddress+1
    sta usedLoadAddress+2
usedLoadAddress:
    jsr $0000
    jsr initTerminal

!return:
    rts

// ========================================

copyRunCommandParameter:
    lda inpBufLen                           // INP_BUF_LEN - 5 = length of parameter to print
    cmp #5
    bcc !return+                            // A<5 = no parameter
    sec
    sbc #4
    sta paramLength

    ldx #5                                  // copy start of parameter to source address
    stx curPosX
    jsr calcCurPos
    lda cursor
    sta sourceAddr
    lda cursor+1
    sta sourceAddr+1
                    
    lda #<commandBuffer+3                   // copy command buffer + 3 to destination address
    sta destinationAddr
    lda #>commandBuffer+3
    sta destinationAddr+1

    ldy #0                                  // copy parameter to buffer until a $00 is reached
!loop:
    cpy paramLength
    beq !return+
    lda (sourceAddr),Y
    sta (destinationAddr),y
    iny
    jmp !loop-

!return:
    rts

// ========================================

copyReadWriteBufferToMemory:
    lda #<readWriteBuffer+2                 // copy R/W buffer + 2 to source address
    sta sourceAddr
    lda #>readWriteBuffer+2
    sta sourceAddr+1

    lda loadAddressCursor                   // copy load address destination address
    sta destinationAddr
    lda loadAddressCursor+1
    sta destinationAddr+1

    ldy #0                                  // copy buffer to destination address
!loop:
    cpy readWriteBuffer+1                   // readWriteBuffer + 1 stores the line length
    beq !return+
    lda (sourceAddr),y
    sta (destinationAddr),y
    iny
    jmp !loop-

!return:
    lda loadAddressCursor                   // load address is increaased by buffer size for next run
    clc
    adc readWriteBuffer+1
    sta loadAddressCursor
    lda loadAddressCursor+1
    adc #0
    sta loadAddressCursor+1
    
    rts

// ========================================