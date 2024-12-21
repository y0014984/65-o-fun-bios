// ========================================

#importonce 

// ========================================

.label foregroundColor      = $020A
.label backgroundColor      = $020B

.label biosStart            = $9000

.label hardwareVectors      = $FFFA

.label softwareVectors      = $FFF6

.label NMIB                 = $FFFA
.label RESB                 = $FFFC
.label IRQB                 = $FFFE

// ========================================

.label sourceAddr           = $F8           // WORD $F8 + $F9
.label destinationAddr      = $FA           // WORD $FA + $FB 

// ========================================