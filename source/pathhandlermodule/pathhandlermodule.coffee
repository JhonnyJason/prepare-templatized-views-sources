pathhandlermodule = {name: "pathhandlermodule"}
############################################################
#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pathhandlermodule"]?  then console.log "[pathhandlermodule]: " + arg
    return
olog = (o) -> log "\n" + ostr(o)
ostr = (o) -> JSON.stringify(o, null, 4)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region node_modules
fs = require("fs")
pathModule = require("path")
os = require "os"

#endregion

############################################################
#region properties
homedir = os.homedir()
templates = {}
templateExtension = ".mustache"
contentExtension = ".json"

############################################################
#region exposedProperties
pathhandlermodule.homedir = homedir #directory
pathhandlermodule.unpreparedPath = "" #directory
pathhandlermodule.contentPath = "" #directory
pathhandlermodule.outputPath = "" #directory
#endregion
#endregion

############################################################
pathhandlermodule.initialize = () ->
    log "pathhandlermodule.initialize"
    return

############################################################
#region internalFunctions
resolveHomeDir = (path) ->
    log "resolveHomeDir"
    if !path then return
    if path[0] == "~"
        path = path.replace("~", homedir)
    return path

checkDirectoryExists = (path) ->
    try
        stats = fs.lstatSync(path)
        return stats.isDirectory()
    catch err
        log err
        return false

digestUnprepared = ->
    log "digestUnprepared"
    files = fs.readdirSync(pathhandlermodule.unpreparedPath)
    len = templateExtension.length
    # filter out the files with extension of .mustache
    files = files.filter((file) -> file.substr(file.length - len, len) == templateExtension)
    # olog files
    # get rid of extension
    files = files.map((file) -> file.substr(0, file.length-len))
    # assign to templates 
    files.forEach((file) -> templates[file] = false )
    olog templates
    return

digestContent = ->
    log "digestContent"
    files = fs.readdirSync(pathhandlermodule.contentPath)
    len = contentExtension.length
    # filter out the files with extension of .json
    files = files.filter((file) -> file.substr(file.length - len, len) == contentExtension)
    files = files.map((file) -> file.substr(0, file.length-len))
    olog files
    templates[file] = true for file in files when templates[file]?
    olog templates
    return

createFilePathsObject = (filename) ->
    log "createUnpreparedPair"
    templatePath = pathModule.resolve(pathhandlermodule.unpreparedPath, filename+templateExtension)
    contentPath = pathModule.resolve(pathhandlermodule.contentPath, filename+contentExtension)
    outputPath = pathModule.resolve(pathhandlermodule.outputPath, filename+templateExtension)
    return {templatePath, contentPath, outputPath}

#endregion

############################################################
#region exposedFunctions
pathhandlermodule.preparePathsOfUnprepared = (unpreparedPath) ->
    log "pathhandlermodule.preparePathsOfUnprepared"
    log unpreparedPath
    if !unpreparedPath then throw new Error("Error, path to unprepared was empty!")
    
    unpreparedPath = resolveHomeDir(unpreparedPath)
    if pathModule.isAbsolute(unpreparedPath)
        pathhandlermodule.unpreparedPath = unpreparedPath
    else
        pathhandlermodule.unpreparedPath = pathModule.resolve(process.cwd(), unpreparedPath)    
    log "our unpreparedPath is: " + pathhandlermodule.unpreparedPath

    exists = await checkDirectoryExists(pathhandlermodule.unpreparedPath)
    if !exists
        throw new Error("No directory exists, for the provided unprepared path!")

    await digestUnprepared()

    return

pathhandlermodule.preparePathsOfContent = (contentPath) ->
    log "pathhandlermodule.preparePathsOfContent"
    log contentPath
    if !contentPath then throw new Error("Error, path to content was empty!")

    contentPath = resolveHomeDir(contentPath)
    if pathModule.isAbsolute(contentPath)
        pathhandlermodule.contentPath = contentPath
    else
        pathhandlermodule.contentPath = pathModule.resolve(process.cwd(), contentPath)    
    log "our contentPath is: " + pathhandlermodule.contentPath

    exists = await checkDirectoryExists(pathhandlermodule.contentPath)
    if !exists
        throw new Error("No directory exists, for the provided content path!")

    await digestContent()

    return

pathhandlermodule.checkOutputPath = (outputPath) ->
    log "pathhandlermodule.preparePathsOfOutput"
    log outputPath
    if !outputPath then throw "Error, path to output was empty!"

    outputPath = resolveHomeDir(outputPath)
    if pathModule.isAbsolute(outputPath)
        pathhandlermodule.outputPath = outputPath
    else
        pathhandlermodule.outputPath = pathModule.resolve(process.cwd(), outputPath)    
    log "our outputPath is: " + pathhandlermodule.outputPath

    exists = await checkDirectoryExists(pathhandlermodule.outputPath)
    if !exists
        throw new Error("No directory exists, for the provided output path!")

    return

############################################################
pathhandlermodule.getFilePathObjects = ->
    log "pathhandlermodule.getUnpreparedMustaches"
    result = []
    for file,exists of templates
        if exists then result.push createFilePathsObject(file) 
    return result

#endregion

module.exports = pathhandlermodule