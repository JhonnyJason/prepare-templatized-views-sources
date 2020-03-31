cliargumentsmodule = {name: "cliargumentsmodule"}
##############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["cliargumentsmodule"]?  then console.log "[cliargumentsmodule]: " + arg
    return

##############################################################
meow = require("meow")

##############################################################
cliargumentsmodule.initialize = () ->
    log "cliargumentsmodule.initialize"
    return

##############################################################
#region internalFunctions
getOptions = ->
    log "getOptions"
    return {
        flags:
            unprepared: 
                type: "string" 
                alias: "p"
            content:
                type: "string"
                alias: "c"
            output:
                type: "string"
                alias: "o"
    }

getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ prepare-templatized-views <arg1> <arg2> <arg3>
    
        Options
            required:
                arg1, --unprepared, -p
                    path to the directory holding the unprepared templates
                    may be relative or absolute
                arg2, --content, -c
                    path to the directory holding the contentObjects
                    may be relative or absolute
                arg3, --output, -o
                    path to the directory where to write our prepared templates
                    may be relative or absolute

        Examples
            $  prepare-templatized-views templates/unprepared content templates/prepared
            ...
    """

extractMeowed = (meowed) ->
    log "extractMeowed"

    unprepared = ""
    content = ""
    output = ""

    if meowed.input[0]
        unprepared = meowed.input[0]
    if meowed.input[1]
        content = meowed.input[1]
    if meowed.input[2]
        output = meowed.input[2]


    if meowed.flags.unprepared then unprepared  = meowed.flags.unprepared
    if meowed.flags.content then content = meowed.flags.content
    if meowed.flags.output then output = meowed.flags.output

    if !unprepared then throw "Usage Error, we require a path to the unprepared templates!"
    if !content then throw "Usage Error, we require a path to the content objects!"
    if !output then throw "Usage Error, we require a path to write our prepared templates to!"

    return {unprepared, content, output}

#endregion

##############################################################
cliargumentsmodule.extractArguments = ->
    log "cliargumentsmodule.extractArguments"
    options = getOptions()
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    return extract

module.exports = cliargumentsmodule