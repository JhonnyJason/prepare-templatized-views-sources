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
decamelize = require "decamelize"

############################################################
pathHandler = null

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
    log filePaths.templatePath
    template = await readFile(filePaths.templatePath)
    content = require filePaths.contentPath
    $ = cheerio.load(template)
    head = $("head")
    body = $("body")

    prepareBody($, body, content)

    ##Append other stuff
    head.append("{{{headInclude}}}\n")
    body.append("{{{adminPanel}}}\n")
    body.append("{{{scriptInclude}}}\n")
    
    fs.writeFile(filePaths.outputPath, $.html(), () -> return)
    return

prepareBody = ($, cheerioBody, content) ->
    log "prepareBody"
    prepareAllTexts($,cheerioBody)
    # prepareAllLinks($,cheerioBody, content)
    # prepareAllImages($,cheerioBody, content)
    prepareAllLists($, cheerioBody, content)
    
    return

############################################################
prepareAllLists = ($, cheerioBody, content) ->
    log "prepareAllLists"
    allListKeys = searchArrays("sharedContent", content.sharedContent)
    allListKeys = allListKeys.concat(searchArrays("content", content.content))
    for listKey in allListKeys
        prepareList($, cheerioBody, content, listKey)
    return

searchArrays = (prefix, obj) ->
    log "searchArrays"
    if typeof obj != "object" then return
    result = []
    for key,sub of obj
        newResults = searchArrays(prefix+"."+key, sub)
        if !newResults then continue
        if Array.isArray(sub) then newResults.push(prefix+"."+key)
        result = result.concat(newResults)
    return result


prepareList = ($, cheerioBody, content, listKey) ->
    log "prepareList"
    keyTokens = listKey.split(".")
    token = keyTokens.shift()
    listObject = content[token]
    listObject = listObject[token] for token in keyTokens
    if typeof listObject[0] == "string" then prepareTextList($, cheerioBody,listKey)
    else prepareObjectList($, cheerioBody, listKey, listObject)
    return

prepareTextList = ($, cheerioBody, listKey) ->
    log "prepareTextList"
    selector = "[text-content-key='"+listKey+".0']"
    log selector
    firstElement = cheerioBody.find(selector).first()
    listParent = firstElement.parent()
    listParent.attr("list-content-key", listKey)
    return

prepareObjectList = ($, cheerioBody, listKey, listObject) ->
    log "prepareObjectList"
    return

############################################################
prepareAllImages = ($, cheerioBody, content) ->
    log "prepareAllImages"
    allImages = Object.keys(content.images)
    prepareImage($, cheerioBody, image) for image in allImages
    return

prepareImage = ($, cheerioBody, image) ->
    log "prepareImage"
    log image
    imageId = decamelize(image, "-")
    log imageId
    cheerioImage = cheerioBody.find("#"+imageId).first()
    cheerioImage.attr("image-content-key", image)
    return

############################################################
prepareAllLinks = ($, cheerioBody) ->
    log "prepareAllLinks"
    allLinks = cheerioBody.find("a")
    log allLinks.length
    prepareLinkNode $,link for link in allLinks when isContentLink($,link)
    return

isContentLink = ($, link) ->
    log "isContentLink"
    cheerioLink = $(link)
    href = cheerioLink.attr("href")
    identifier = ".ref}}}"
    index = href.lastIndexOf(identifier)
    return index == (href.length - identifier.length)

prepareLinkNode = ($, link) ->
    log "prepareLinkNode"
    cheerioLink = $(link)
    linkContentKey = cheerioLink.attr("href").replace(/{/g, "").replace(/}/g, "")
    cheerioLink.attr("link-content-key", linkContentKey)
    return

############################################################
prepareAllTexts = ($, cheerioBody) ->
    log "prepareAllTexts"
    children = cheerioBody.children()
    log '@Body we have ' + children.length + ' children!'
    prepareTextNode $,child for child in children #when !($(child).is('script'))
    return

prepareTextNode = ($, node) ->
    log "prepareNode"
    cheerioNode = $(node)    
    if hasNoText(cheerioNode) then return
    
    children = cheerioNode.children()
    if children.length == 0
        # log "-----"
        # log "found leaf at " + node.tagName + " " + id
        # log cheerioNode.text()
        textContentKey = cheerioNode.text().replace(/{/g, "").replace(/}/g, "").replace(/\s/g, "")
        # log textContentKey
        cheerioNode.attr("text-content-key", textContentKey)
        return

    prepareTextNode $,child for child in children #when !($(child).is('script'))
    return

hasNoText = (cheerioNode) ->
    text = cheerioNode.text()
    if text then text = text.replace(/\s/g, '')
    if text then return false
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
    # olog filePathObjects
    # promises = (prepare(filePathObject) for filePathObject in filePathObjects)
    # await Promise.all(promises)
    await prepare(filePathObjects[0])
    return

module.exports = preparationmodule