// ========================================

#importonce 

// ========================================

.label foregroundColor      = $020A
.label backgroundColor      = $020B

.label biosStart            = $9000

.label fontStart            = $D000

.label hardwareVectors      = $FFFA

.label softwareVectors      = $FFF6

.label NMIB                 = $FFFA
.label RESB                 = $FFFC
.label IRQB                 = $FFFE

// ========================================

.label sourceAddr           = $F8           // WORD $F8 + $F9
.label destinationAddr      = $FA           // WORD $FA + $FB

// ========================================

.label dateTimeYear         = $020C
.label dateTimeWeekdayMonth = $020E
.label dateTimeDay          = $020F
.label dateTimeHours        = $0210
.label dateTimeMinutes      = $0211
.label dateTimeSeconds      = $0212

// ========================================

.label storageAddrBufRW     = $0217         // WORD $0217 + $0218
.label storageLenBufRW      = $0219
.label storageAddrBufCom    = $021A         // WORD $021A + $021B
.label storageLenBufCom     = $021C
.label storageComRetVal     = $021D
.label storageComFlow       = $021F

// ========================================