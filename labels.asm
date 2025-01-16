// ========================================

#importonce 

// ========================================

.label screenMemStart       = $0400
.label biosStart            = $D000
.label fontStart            = $F400

.label hardwareVectors      = $FFFA
.label softwareVectors      = $FFF6

.label NMIB                 = $FFFA
.label RESB                 = $FFFC
.label IRQB                 = $FFFE

// ========================================

.label sourceAddr           = $F8           // WORD $F8 + $F9
.label destinationAddr      = $FA           // WORD $FA + $FB

// ========================================

.label foregroundColor      = $020A
.label backgroundColor      = $020B

// ========================================

.label dateTimeYear         = $020C         // WORD $020C + $020D
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
.label storageComLastErr    = $021E
.label storageComFlow       = $021F

// ========================================

.label colorMode            = $0227
.label colorTableAddr       = $0228         // WORD $0228 + $0229
.label tileModeOrientation  = $022A
.label tileMapWidth         = $022B
.label tileMapHeight        = $022C
.label tileMapAddr          = $022D         // WORD $022D + $022E
.label tileSetAddr          = $022F         // WORD $022F + §0230
.label tileSetLength        = $0231

// ========================================