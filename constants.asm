// ========================================

#importonce 

// ========================================

.const screenWidth          = 40            // 40 chars width * 8 = 320px
.const screenHeight         = 30            // 30 chars height * 8 = 240px

// ========================================

.const charPilcrowSign      = $14           // used as line break symbol in 'bono'
.const charSpace            = $20
.const charAsterisk         = $2A
.const charComma            = $2C
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