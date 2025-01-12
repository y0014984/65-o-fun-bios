// ========================================

#importonce

#import "../labels.asm"
#import "../constants.asm"

// ========================================

.label readWriteBuffer = $0300
.const readWriteBufferLength = 32
.label commandBuffer = $0320
.const commandBufferLength = 32

// ========================================

initStorage:
    lda #<readWriteBuffer
    sta storageAddrBufRW
    lda #>readWriteBuffer
    sta storageAddrBufRW + 1
    lda #readWriteBufferLength
    sta storageLenBufRW

    lda #<commandBuffer
    sta storageAddrBufCom
    lda #>commandBuffer
    sta storageAddrBufCom + 1
    lda #commandBufferLength
    sta storageLenBufCom

!return:
    rts

// ========================================

getFilesystemObjectCount:
    lda #'F'
    sta commandBuffer
    lda #'O'
    sta commandBuffer+1
    lda #'C'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

getFilesystemObjectType:
    sta commandBuffer+3

    lda #'G'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'T'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal
    ldx readWriteBuffer

!return:
    rts

// ========================================

getFileSize:
    sta commandBuffer+3

    jsr clearReadWriteBuffer

    lda #'G'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'S'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal
    ldx readWriteBuffer
    ldy readWriteBuffer+1

!return:
    rts

// ========================================

getFilesystemObjectName:
    sta commandBuffer+3

    jsr clearReadWriteBuffer

    lda #'G'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'N'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

gotoDirectory:
    lda #'G'
    sta commandBuffer
    lda #'T'
    sta commandBuffer+1
    lda #'D'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

createDirectory:
    lda #'C'
    sta commandBuffer
    lda #'R'
    sta commandBuffer+1
    lda #'D'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

removeDirectory:
    lda #'R'
    sta commandBuffer
    lda #'M'
    sta commandBuffer+1
    lda #'D'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

createFile:
    lda #'C'
    sta commandBuffer
    lda #'R'
    sta commandBuffer+1
    lda #'F'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

removeFile:
    lda #'R'
    sta commandBuffer
    lda #'M'
    sta commandBuffer+1
    lda #'F'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

getWorkingDirectory:
    lda #'G'
    sta commandBuffer
    lda #'W'
    sta commandBuffer+1
    lda #'D'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

existsFilesystemObject:
    lda #'E'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'O'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

isFile:
    lda #'I'
    sta commandBuffer
    lda #'S'
    sta commandBuffer+1
    lda #'F'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

isProgram:
    lda #'I'
    sta commandBuffer
    lda #'S'
    sta commandBuffer+1
    lda #'P'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

getLoadAddress:
    lda #'G'
    sta commandBuffer
    lda #'L'
    sta commandBuffer+1
    lda #'A'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

saveFileContent:
    lda #'S'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'C'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

appendFileContent:
    lda #'A'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'C'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

readFileContent:
    lda #'R'
    sta commandBuffer
    lda #'F'
    sta commandBuffer+1
    lda #'C'
    sta commandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

waitForStorageResult:
!loop:
    lda storageComFlow
    cmp #commandFlowDone
    bne !loop-

    jsr clearCommandBuffer

!return:
    rts

// ========================================

clearCommandBuffer:
    ldy #0
!loop:
    lda #$00
    sta commandBuffer,y
    iny
    cpy #commandBufferLength
    beq !return+
    jmp !loop-

!return:
    rts

// ========================================

clearReadWriteBuffer:
    ldy #0
!loop:
    lda #$00
    sta readWriteBuffer,y
    iny
    cpy #readWriteBufferLength
    beq !return+
    jmp !loop-

!return:
    rts

// ========================================