configmodule = {name: "configmodule"}
############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

############################################################
configmodule.cli =
    name: "prepare-templatized-views"

############################################################
configmodule.initialize = () ->
    log "configmodule.initialize"
    return

module.exports = configmodule