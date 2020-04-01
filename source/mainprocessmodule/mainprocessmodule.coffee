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
pathHandler = null
preparation = null

############################################################
mainprocessmodule.initialize = () ->
    log "mainprocessmodule.initialize"
    cfg = allModules.configmodule
    pathHandler = allModules.pathhandlermodule
    preparation = allModules.preparationmodule
    return 

############################################################
mainprocessmodule.execute = (e) ->
    log "mainprocessmodule.execute"

    await pathHandler.preparePathsOfUnprepared(e.unprepared)
    await pathHandler.preparePathsOfContent(e.content)
    await pathHandler.checkOutputPath(e.output)
    
    await preparation.execute()

    return

module.exports = mainprocessmodule
