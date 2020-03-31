mainprocessmodule = {name: "mainprocessmodule"}
############################################################
#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["mainprocessmodule"]?  then console.log "[mainprocessmodule]: " + arg
    return
olog = (o) -> log "\n" + ostr(o)
ostr = (o) -> JSON.stringify(o, null, 4)
print = (arg) -> console.log(arg)
#endregion

############################################################
cfg = null

############################################################
mainprocessmodule.initialize = () ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    return 

############################################################
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"
    olog e
    return

module.exports = mainprocessmodule
