// ========================================

#importonce

#import "../labels.asm"
#import "../constants.asm"

// ========================================

.label tmpReadWriteBuffer = $0300
.const tmpReadWriteBufferLength = 32
.label tmpCommandBuffer = $0320
.const tmpCommandBufferLength = 32

// ========================================

initStorage:
    lda #<tmpReadWriteBuffer
    sta storageAddrBufRW
    lda #>tmpReadWriteBuffer
    sta storageAddrBufRW + 1
    lda #tmpReadWriteBufferLength
    sta storageLenBufRW

    lda #<tmpCommandBuffer
    sta storageAddrBufCom
    lda #>tmpCommandBuffer
    sta storageAddrBufCom + 1
    lda #tmpCommandBufferLength
    sta storageLenBufCom

!return:
    rts

// ========================================

getFilesystemObjectCount:
    lda #'F'
    sta tmpCommandBuffer
    lda #'O'
    sta tmpCommandBuffer+1
    lda #'C'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

getFilesystemObjectType:
    sta tmpCommandBuffer+3

    lda #'G'
    sta tmpCommandBuffer
    lda #'F'
    sta tmpCommandBuffer+1
    lda #'T'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal
    ldx tmpReadWriteBuffer

!return:
    rts

// ========================================

getFileSize:
    sta tmpCommandBuffer+3

    jsr clearReadWriteBuffer

    lda #'G'
    sta tmpCommandBuffer
    lda #'F'
    sta tmpCommandBuffer+1
    lda #'S'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal
    ldx tmpReadWriteBuffer
    ldy tmpReadWriteBuffer+1

!return:
    rts

// ========================================

getFilesystemObjectName:
    sta tmpCommandBuffer+3

    jsr clearReadWriteBuffer

    lda #'G'
    sta tmpCommandBuffer
    lda #'F'
    sta tmpCommandBuffer+1
    lda #'N'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

gotoDirectory:
    lda #'G'
    sta tmpCommandBuffer
    lda #'T'
    sta tmpCommandBuffer+1
    lda #'D'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

createDirectory:
    lda #'C'
    sta tmpCommandBuffer
    lda #'R'
    sta tmpCommandBuffer+1
    lda #'D'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

removeDirectory:
    lda #'R'
    sta tmpCommandBuffer
    lda #'M'
    sta tmpCommandBuffer+1
    lda #'D'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

createFile:
    lda #'C'
    sta tmpCommandBuffer
    lda #'R'
    sta tmpCommandBuffer+1
    lda #'F'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

removeFile:
    lda #'R'
    sta tmpCommandBuffer
    lda #'M'
    sta tmpCommandBuffer+1
    lda #'F'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

getWorkingDirectory:
    lda #'G'
    sta tmpCommandBuffer
    lda #'W'
    sta tmpCommandBuffer+1
    lda #'D'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

existsFilesystemObject:
    lda #'E'
    sta tmpCommandBuffer
    lda #'F'
    sta tmpCommandBuffer+1
    lda #'O'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

isFile:
    lda #'I'
    sta tmpCommandBuffer
    lda #'S'
    sta tmpCommandBuffer+1
    lda #'F'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

saveFileContent:
    lda #'S'
    sta tmpCommandBuffer
    lda #'F'
    sta tmpCommandBuffer+1
    lda #'C'
    sta tmpCommandBuffer+2

    lda #commandFlowReady
    sta storageComFlow

    jsr waitForStorageResult

    lda storageComRetVal

!return:
    rts

// ========================================

appendFileContent:
    lda #'A'
    sta tmpCommandBuffer
    lda #'F'
    sta tmpCommandBuffer+1
    lda #'C'
    sta tmpCommandBuffer+2

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
    sta tmpCommandBuffer,y
    iny
    cpy #tmpCommandBufferLength
    beq !return+
    jmp !loop-

!return:
    rts

// ========================================

clearReadWriteBuffer:
    ldy #0
!loop:
    lda #$00
    sta tmpReadWriteBuffer,y
    iny
    cpy #tmpReadWriteBufferLength
    beq !return+
    jmp !loop-

!return:
    rts

// ========================================