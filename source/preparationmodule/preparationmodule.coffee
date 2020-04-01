preparationmodule = {name: "preparationmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["preparationmodule"]?  then console.log "[preparationmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
cheerio = require "cheerio"
fs = require "fs"


############################################################
pathHandler = null

############################################################
ignoredSubTags = ["span", "a", "b", "sup", "img", "strong", "br", "script"]
## Probably we donot need this, as there is no content here^^

############################################################
preparationmodule.initialize = () ->
    log "preparationmodule.initialize"
    pathHandler = allModules.pathhandlermodule
    return

############################################################
#region internalFunctions
readFile = (path) ->
    log "readFile"
    return new Promise (resolve, reject) ->
        callback = (error, data) ->
            if error then reject(error)
            else resolve(data)
            return
        fs.readFile(path,'utf8', callback)
        return

prepare = (filePaths) ->
    log "prepare"
    template = await readFile(filePaths.templatePath)
    content = require filePaths.contentPath
    $ = cheerio.load(template)
    head = $("head")
    body = $("body")
    # olog content

    prepareBody($, body, content)

    ##Append other stuff
    head.append("{{{headInclude}}}\n")
    body.append("{{{adminPanel}}}\n")
    body.append("{{{scriptInclude}}}\n")
    
    fs.writeFile(filePaths.outputPath, $.html(), () -> return)
    return

prepareBody = ($, body, content) ->
    log "prepareBody"
    prepareAllTexts($,body)
    # prepareAllLinks($,body, content)
    # prepareAllImages($,body, content)
    # prepareAllLists($, body, content)

    
    return

prepareAllTexts = ($, body) ->
    log "prepareAllTexts"
    children = body.children()
    log '@Body we have ' + children.length + ' children!'
    prepareNode $,child for child in children when !($(child).is('script'))
    return



isSubTagToIgnore = ($, node) ->
    return true for tag in ignoredSubTags when $(node).is(tag)
    false

prepareNode = ($, node, content) ->
    log "prepareNode"
    # if !node.html() then return
    # if hasNoText(node) then return
    log node.tagName

    # log node.html()
    children = node.children
    
    if !children.length
        log "probably we have reached a leaf :-)"
        log $(node).text()
        return

    log "@Node " + node.id + " we have " + children.length + " children!"
    prepareNode $,child for child in children when !($(child).is('script'))
    return

hasNoText = (node) ->
    text = node.text()
    # log '_____________START'
    # log text
    if text
        # log '_____________REPLACED'
        text = text.replace(/\s/g, '')
        # log text
        if text
            # log ' - - - had Text'
            return false
        # log ' - - - no Text'
    return true


# checkNode = ($, node) ->
#     #log(node.html());
#     if hasNoText(node) then return
   
#     #check next
#     children = node.children()

#   nonNodeElements = 0
#   i = 0
#   while i < children.length
#     if isSubTagToIgnore(children[i])
#       #console.log("!! -  We have a nonNode element here  -  !! ");
#       nonNodeElements++
#     else
#       checkNode $(children[i])
#     i++
#   if !children.length or children.length == nonNodeElements
#     #we have here a leave
#     #console.log("!!!   ---   This Node either had no children at all or it only had links as children!");
#     if !id
#       id = idBase + idCount++
#       node.attr 'id', id
#     node.addClass 'editable-field'
#     content[id] = node.html()
#     node.html '{{{content.' + id + '}}}'
#   return



#endregion

############################################################
preparationmodule.execute = ->
    log "preparationmodule.execute"
    filePathObjects = pathHandler.getFilePathObjects()
    olog filePathObjects
    promises = (prepare(filePathObject) for filePathObject in filePathObjects)
    await Promise.all(promises)
    return

module.exports = preparationmodule