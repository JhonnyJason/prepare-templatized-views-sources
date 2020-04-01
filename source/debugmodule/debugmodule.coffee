debugmodule = {name: "debugmodule"}

##############################################################################
debugmodule.initialize = () ->
    # console.log "debugmodule.initialize - nothing to do"
    return     
##############################################################################
debugmodule.modulesToDebug = 
    unbreaker: true
    # cliargumentsmodule: true
    # configmodule: true
    # mainprocessmodule: true
    # pathhandlermodule: true
    preparationmodule: true
    # startupmodule: true
    
module.exports = debugmodule