// ========================================

#importonce 

// ========================================

.const FALSE                = $00
.const TRUE                 = $FF

// ========================================

.const screenWidth          = 40            // 40 chars width * 8 = 320px
.const screenHeight         = 30            // 30 chars height * 8 = 240px

// ========================================

// ASCII control characters
.const ctrlBackspace        = $08
.const ctrlLineFeed         = $0A
.const ctrlArrowLeft        = $11           // reassignment of device control 1
.const ctrlArrowRight       = $12           // reassignment of device control 2
.const ctrlArrowUp          = $13           // reassignment of device control 3
.const ctrlArrowDown        = $14           // reassignment of device control 4

// Codepage 437 printable characters
.const charPilcrowSign      = $14           // used as line feed replacement in 'bono'
.const charSpace            = $20
.const charAsterisk         = $2A           // used as edit marker in 'bono'
.const charComma            = $2C           // used as separator in 'help' command
.const charGreaterThan      = $3E           // used as prompt in 'bono'
.const charFullBlock        = $DB           // used as cursor in terminal and 'bono'
.const charBulletOperator   = $F9           // used as space replacement in 'bono'

// ========================================

.const commandFlowReady     = $E1
.const commandFlowInProgess = $99
.const commandFlowDone      = $87

.const fsoTypeDirectory     = $E1
.const fsoTypeFile          = $99
.const fsoTypeProgram       = $87

.const errCodeNoFileOrDir   = $C1
.const errCodeNotDir        = $A1
.const errCodeIsDir         = $91
.const errCodeMissingParam  = $89
.const errCodeDirExists     = $85
.const errCodeFileExists    = $83
.const errCodeDirNotEmpty   = $E1
.const errCodeUnknownCom    = $99

// ========================================