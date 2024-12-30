// ========================================

#importonce 

// ========================================

.const screenWidth          = 40        // 40 chars width * 8 = 320px
.const screenHeight         = 30        // 30 chars height * 8 = 240px

// ========================================

.const asciiLineFeed        = $0A
.const asciiSpace           = $20
.const asciiComma           = $2C
.const asciiGreaterThan     = $3E
.const asciiCursor          = $81
.const asciiMiddleDot       = $B7

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