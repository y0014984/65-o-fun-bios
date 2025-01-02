// reference: https://upload.wikimedia.org/wikipedia/commons/1/1b/ASCII-Table-wide.svg

// Manually recreated from C64 font

// Some glyphs newly invented

// Partially referencing codepage 437

// ========================================

.fill $14*8, $00

// ========================================

PilcrowSign:                                // $14
.byte %00000000
.byte %00000110
.byte %00000110
.byte %00000110
.byte %00100110
.byte %01111110
.byte %00100000
.byte %00000000

// ========================================

.fill ($20-$14-1)*8, $00

// ========================================

spaceCharacter:                             // $20
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

exclamationMarkCharacter:                   // $21
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00000000

quotationMarksCharacter:                    // $22
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

numberSignCharacter:                        // $23
.byte %01100110
.byte %01100110
.byte %11111111
.byte %01100110
.byte %11111111
.byte %01100110
.byte %01100110
.byte %00000000

dollarSignCharacter:                        // $24
.byte %00011000
.byte %00111110
.byte %01100000
.byte %00111100
.byte %00000110
.byte %01111100
.byte %00011000
.byte %00000000

percentSignCharacter:                       // $25
.byte %01100010
.byte %01100110
.byte %00001100
.byte %00011000
.byte %00110000
.byte %01100110
.byte %01000110
.byte %00000000

ampersandCharacter:                         // $26
.byte %00111100
.byte %01100110
.byte %00111100
.byte %00111000
.byte %01100111
.byte %01100110
.byte %00111111
.byte %00000000

apostropheCharacter:                        // $27
.byte %00000110
.byte %00001100
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

parenthesisLeftCharacter:                   // $28
.byte %00001100
.byte %00011000
.byte %00110000
.byte %00110000
.byte %00110000
.byte %00011000
.byte %00001100
.byte %00000000

parenthesisRightCharacter:                  // $29
.byte %00110000
.byte %00011000
.byte %00001100
.byte %00001100
.byte %00001100
.byte %00011000
.byte %00110000
.byte %00000000

asteriskCharacter:                          // $2A
.byte %00000000
.byte %01100110
.byte %00111100
.byte %11111111
.byte %00111100
.byte %01100110
.byte %00000000
.byte %00000000

plusSignCharacter:                          // $2B
.byte %00000000
.byte %00011000
.byte %00011000
.byte %01111110
.byte %00011000
.byte %00011000
.byte %00000000
.byte %00000000

commaCharacter:                             // $2C
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00011000
.byte %00110000

minusSignCharacter:                         // $2D
.byte %00000000
.byte %00000000
.byte %00000000
.byte %01111110
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

fullStopCharacter:                          // $2E
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00011000
.byte %00000000

slashCharacter:                             // $2F
.byte %00000000
.byte %00000011
.byte %00000110
.byte %00001100
.byte %00011000
.byte %00110000
.byte %01100000
.byte %00000000

// ========================================

zeroCharacter:                              // $30
.byte %00111100
.byte %01100110
.byte %01101110
.byte %01110110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00000000

oneCharacter:                               // $31
.byte %00011000
.byte %00011000
.byte %00111000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %01111110
.byte %00000000

twoCharacter:                               // $32
.byte %00111100
.byte %01100110
.byte %00000110
.byte %00001100
.byte %00110000
.byte %01100000
.byte %01111110
.byte %00000000

threeCharacter:                             // $33
.byte %00111100
.byte %01100110
.byte %00000110
.byte %00011100
.byte %00000110
.byte %01100110
.byte %00111100
.byte %00000000

fourCharacter:                              // $34
.byte %00000110
.byte %00001110
.byte %00011110
.byte %01100110
.byte %01111111
.byte %00000110
.byte %00000110
.byte %00000000

fiveCharacter:                              // $35
.byte %01111110
.byte %01100000
.byte %01111100
.byte %00000110
.byte %00000110
.byte %01100110
.byte %00111100
.byte %00000000

sixCharacter:                               // $36
.byte %00111100
.byte %01100110
.byte %01100000
.byte %01111100
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00000000

sevenCharacter:                             // $37
.byte %01111110
.byte %01100110
.byte %00001100
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00000000

eightCharacter:                             // $38
.byte %00111100
.byte %01100110
.byte %01100110
.byte %00111100
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00000000

nineCharacter:                              // $39
.byte %00111100
.byte %01100110
.byte %01100110
.byte %00111110
.byte %00000110
.byte %01100110
.byte %00111100
.byte %00000000

colonCharacter:                             // $3A
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00000000
.byte %00000000

semicolonCharacter:                         // $3B
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00011000
.byte %00110000

lessThanSignCharacter:                      // $3C
.byte %00001110
.byte %00011000
.byte %00110000
.byte %01100000
.byte %00110000
.byte %00011000
.byte %00001110
.byte %00000000

equalsSignCharacter:                        // $3D
.byte %00000000
.byte %00000000
.byte %01111110
.byte %00000000
.byte %01111110
.byte %00000000
.byte %00000000
.byte %00000000

greaterThanSignCharacter:                   // $3E
.byte %01110000
.byte %00011000
.byte %00001100
.byte %00000110
.byte %00001100
.byte %00011000
.byte %01110000
.byte %00000000

questionMarkCharacter:                      // $3F
.byte %00111100
.byte %01100110
.byte %00000110
.byte %00001100
.byte %00011000
.byte %00000000
.byte %00011000
.byte %00000000

// ========================================

atSignCharacter:                            // $40
.byte %00111100
.byte %01100110
.byte %01101110
.byte %01101110
.byte %01100000
.byte %01100010
.byte %00111100
.byte %00000000

upperCaseACharacter:                        // $41
.byte %00011000
.byte %00111100
.byte %01100110
.byte %01111110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00000000

upperCaseBCharacter:                        // $42
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01111100
.byte %00000000

upperCaseCCharacter:                        // $43
.byte %00111100
.byte %01100110
.byte %01100000
.byte %01100000
.byte %01100000
.byte %01100110
.byte %00111100
.byte %00000000

upperCaseDCharacter:                        // $44
.byte %01111000
.byte %01101100
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01101100
.byte %01111000
.byte %00000000

upperCaseECharacter:                        // $45
.byte %01111110
.byte %01100000
.byte %01100000
.byte %01111000
.byte %01100000
.byte %01100000
.byte %01111110
.byte %00000000

upperCaseFCharacter:                        // $46
.byte %01111110
.byte %01100000
.byte %01100000
.byte %01111000
.byte %01100000
.byte %01100000
.byte %01100000
.byte %00000000

upperCaseGCharacter:                        // $47
.byte %00111100
.byte %01100110
.byte %01100000
.byte %01101110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00000000

upperCaseHCharacter:                        // $$8
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01111110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00000000

upperCaseICharacter:                        // $49
.byte %00111100
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00111100
.byte %00000000

upperCaseJCharacter:                        // $4A
.byte %00011110
.byte %00001100
.byte %00001100
.byte %00001100
.byte %00001100
.byte %01101100
.byte %00111000
.byte %00000000

upperCaseKCharacter:                        // $4B
.byte %01100110
.byte %01101100
.byte %01111000
.byte %01110000
.byte %01111000
.byte %01101100
.byte %01100110
.byte %00000000

upperCaseLCharacter:                        // $4C
.byte %01100000
.byte %01100000
.byte %01100000
.byte %01100000
.byte %01100000
.byte %01100000
.byte %01111110
.byte %00000000

upperCaseMCharacter:                        // $4D
.byte %01100011
.byte %01110111
.byte %01111111
.byte %01101011
.byte %01100011
.byte %01100011
.byte %01100011
.byte %00000000

upperCaseNCharacter:                        // $4E
.byte %01100110
.byte %01110110
.byte %01111110
.byte %01111110
.byte %01101110
.byte %01100110
.byte %01100110
.byte %00000000

upperCaseOCharacter:                        // $4F
.byte %00111100
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00000000

// ========================================

upperCasePCharacter:                        // $50
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01111100
.byte %01100000
.byte %01100000
.byte %01100000
.byte %00000000

upperCaseQCharacter:                        // $51
.byte %00111100
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00001110
.byte %00000000

upperCaseRCharacter:                        // $52
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01111100
.byte %01111000
.byte %01101100
.byte %01100110
.byte %00000000

upperCaseSCharacter:                        // $53
.byte %00111100
.byte %01100110
.byte %01100000
.byte %00111100
.byte %00000110
.byte %01100110
.byte %00111100
.byte %00000000

upperCaseTCharacter:                        // $54
.byte %01111110
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00000000

upperCaseUCharacter:                        // $55
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00000000

upperCaseVCharacter:                        // $56
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00011000
.byte %00000000

upperCaseWCharacter:                        // $57
.byte %01100011
.byte %01100011
.byte %01100011
.byte %01101011
.byte %01111111
.byte %01110111
.byte %01100011
.byte %00000000

upperCaseXCharacter:                        // $58
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00011000
.byte %00111100
.byte %01100110
.byte %01100110
.byte %00000000

upperCaseYCharacter:                        // $59
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00000000

upperCaseZCharacter:                        // $5A
.byte %01111110
.byte %00000110
.byte %00001100
.byte %00011000
.byte %00110000
.byte %01100000
.byte %01111110
.byte %00000000

bracketLeftCharacter:                       // $5B
.byte %00111100
.byte %00110000
.byte %00110000
.byte %00110000
.byte %00110000
.byte %00110000
.byte %00111100
.byte %00000000

backslashCharacter:                         // $5C
.byte %00000000
.byte %01100000
.byte %00110000
.byte %00011000
.byte %00001100
.byte %00000110
.byte %00000011
.byte %00000000

bracketRightCharacter:                      // $5D
.byte %00111100
.byte %00001100
.byte %00001100
.byte %00001100
.byte %00001100
.byte %00001100
.byte %00111100
.byte %00000000

circumflexCharacter:                        // $5E
.byte %00011000
.byte %00111100
.byte %01100110
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

underscoreCharacter:                        // $5F
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %01111110
.byte %00000000

// ========================================

graveCharacter:                             // $60
.byte %01100000
.byte %00110000
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

lowerCaseACharacter:                        // $61
.byte %00000000
.byte %00000000
.byte %00111100
.byte %00000110
.byte %00111110
.byte %01100110
.byte %00111110
.byte %00000000

lowerCaseBCharacter:                        // $62
.byte %00000000
.byte %01100000
.byte %01100000
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01111100
.byte %00000000

lowerCaseCCharacter:                        // $63
.byte %00000000
.byte %00000000
.byte %00111100
.byte %01100000
.byte %01100000
.byte %01100000
.byte %00111100
.byte %00000000

lowerCaseDCharacter:                        // $64
.byte %00000000
.byte %00000110
.byte %00000110
.byte %00000110
.byte %00111110
.byte %01100110
.byte %00111110
.byte %00000000

lowerCaseECharacter:                        // $65
.byte %00000000
.byte %00000000
.byte %00111100
.byte %01100110
.byte %01111110
.byte %01100000
.byte %00111100
.byte %00000000

lowerCaseFCharacter:                        // $66
.byte %00000000
.byte %00001110
.byte %00011000
.byte %00111110
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00000000

lowerCaseGCharacter:                        // $67
.byte %00000000
.byte %00000000
.byte %00111110
.byte %01100110
.byte %01100110
.byte %00111110
.byte %00000110
.byte %01111100

lowerCaseHCharacter:                        // $68
.byte %00000000
.byte %01100000
.byte %01100000
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00000000

lowerCaseICharacter:                        // $69
.byte %00000000
.byte %00011000
.byte %00000000
.byte %00111000
.byte %00011000
.byte %00011000
.byte %00111100
.byte %00000000

lowerCaseJCharacter:                        // $6A
.byte %00000000
.byte %00000110
.byte %00000000
.byte %00000110
.byte %00000110
.byte %00000110
.byte %00000110
.byte %00111100

lowerCaseKCharacter:                        // $6B
.byte %00000000
.byte %01100000
.byte %01100000
.byte %01101100
.byte %01111000
.byte %01101100
.byte %01100110
.byte %00000000

lowerCaseLCharacter:                        // $6C
.byte %00000000
.byte %00111000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00111100
.byte %00000000

lowerCaseMCharacter:                        // $6D
.byte %00000000
.byte %00000000
.byte %01100110
.byte %01111111
.byte %01111111
.byte %01101011
.byte %01100011
.byte %00000000

lowerCaseNCharacter:                        // $6E
.byte %00000000
.byte %00000000
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00000000

lowerCaseOCharacter:                        // $6F
.byte %00000000
.byte %00000000
.byte %00111100
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00000000

// ========================================

lowerCasePCharacter:                        // $70
.byte %00000000
.byte %00000000
.byte %01111100
.byte %01100110
.byte %01100110
.byte %01111100
.byte %01100000
.byte %01100000

lowerCaseQCharacter:                        // $71
.byte %00000000
.byte %00000000
.byte %00111110
.byte %01100110
.byte %01100110
.byte %00111110
.byte %00000110
.byte %00000110

lowerCaseRCharacter:                        // $72
.byte %00000000
.byte %00000000
.byte %01111100
.byte %01100110
.byte %01100000
.byte %01100000
.byte %01100000
.byte %00000000

lowerCaseSCharacter:                        // $73
.byte %00000000
.byte %00000000
.byte %00111110
.byte %01100000
.byte %00111100
.byte %00000110
.byte %01111100
.byte %00000000

lowerCaseTCharacter:                        // $74
.byte %00000000
.byte %00011000
.byte %01111110
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00001110
.byte %00000000

lowerCaseUCharacter:                        // $75
.byte %00000000
.byte %00000000
.byte %01100110
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111110
.byte %00000000

lowerCaseVCharacter:                        // $76
.byte %00000000
.byte %00000000
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111100
.byte %00011000
.byte %00000000

lowerCaseWCharacter:                        // $77
.byte %00000000
.byte %00000000
.byte %01100011
.byte %01100011
.byte %01101011
.byte %00111110
.byte %00110110
.byte %00000000

lowerCaseXCharacter:                        // $78
.byte %00000000
.byte %00000000
.byte %01100110
.byte %00111000
.byte %00011000
.byte %00111100
.byte %01100110
.byte %00000000

lowerCaseYCharacter:                        // $79
.byte %00000000
.byte %00000000
.byte %01100110
.byte %01100110
.byte %01100110
.byte %00111110
.byte %00001100
.byte %01111000

lowerCaseZCharacter:                        // $7A
.byte %00000000
.byte %00000000
.byte %01111110
.byte %00001100
.byte %00011000
.byte %00110000
.byte %01111110
.byte %00000000

braceLeftCharacter:                         // $7B
.byte %00011000
.byte %00110000
.byte %00110000
.byte %01100000
.byte %00110000
.byte %00110000
.byte %00011000
.byte %00000000

pipeCharacter:                              // $7C
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00000000

braceRightCharacter:                        // $7D
.byte %00011000
.byte %00001100
.byte %00001100
.byte %00000110
.byte %00001100
.byte %00001100
.byte %00011000
.byte %00000000

tildeCharacter:                             // $7E
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00110001
.byte %01111111
.byte %01000110
.byte %00000000
.byte %00000000

// ========================================

.fill ($DB-$7E-1)*8, $00

// ========================================

cursorCharacter:                            // $DB
.byte %11111111
.byte %11111111
.byte %11111111
.byte %11111111
.byte %11111111
.byte %11111111
.byte %11111111
.byte %11111111

// ========================================

.fill ($F9-$DB-1)*8, $00

// ========================================

bulletOperator:                             // $F9
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00011000
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00000000

// ========================================

.fill ($FF-$F9)*8, $00

// ========================================