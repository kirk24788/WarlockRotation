--[[
LOGGING

Usage in your code:
    local LOG=Logger(LogLevel.DEBUG)
    LOG.debug("debug message")
    LOG.debug("this is a number: %s", 2)
    /script Logger(LogLevel.DEBUG).debug("test!")
]]--


LogLevel={ DEBUG=1, INFO=2, WARN=3, ERROR=4, NONE=5 }
local function split(str, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
local function logPrint(logLevel,msgLevel)
    return function (msg,a,b,c,d,e,f,g,h)
        if msgLevel >= logLevel then
            local stackTrace = split(debugstack(2,1,0), ":")
            local file  = split(stackTrace[1], "\\")
            --local prefix = ""
            local prefix = string.format("%s:%s - ", file[#file], stackTrace[2])--string.format("%s:%s - ", debug.getinfo(1, "S").short_src, debug.getinfo(2, "l").currentline)
            --TODO: Check if DEFAULT_CHAT_FRAME:AddMessage() has any significant advantages
            print(prefix .. string.format(msg, tostring(a), tostring(b), tostring(c), tostring(d), tostring(e), tostring(f), tostring(g), tostring(h)) )
        end
    end
end

function Logger(level)
    local newLogger = {}
    if not level or not tonumber(level) or (level < LogLevel.DEBUG and level > LogLevel.NONE) then
        newLogger["logLevel"] = LogLevel.NONE
    else
        newLogger["logLevel"] = level
    end
    newLogger["debug"] = logPrint(newLogger.logLevel, LogLevel.DEBUG)
    newLogger["info"] = logPrint(newLogger.logLevel, LogLevel.INFO)
    newLogger["warn"] = logPrint(newLogger.logLevel, LogLevel.WARN)
    newLogger["error"] = logPrint(newLogger.logLevel, LogLevel.ERROR)
    newLogger["isDebugEnabled"] = newLogger.logLevel <= LogLevel.DEBUG
    newLogger["isInfoEnabled"] = newLogger.logLevel <= LogLevel.INFO
    newLogger["isWarnEnabled"] = newLogger.logLevel <= LogLevel.WARN
    newLogger["isErrorEnabled"] = newLogger.logLevel <= LogLevel.ERROR
    return newLogger
end