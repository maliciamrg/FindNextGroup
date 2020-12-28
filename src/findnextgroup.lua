local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrSelection = import 'LrSelection'
local LrView = import "LrView"
local LrBinding = import "LrBinding"
local LrDialogs = import "LrDialogs"
local LrFunctionContext = import "LrFunctionContext"

local LrLogger = import 'LrLogger'
local logger = LrLogger('FindNextGroupPlugin')
logger:enable("logfile")

LrTasks.startAsyncTask(function()
    local catalog = LrApplication.activeCatalog()

    logger:trace("START")
    local photo = catalog:getTargetPhoto()
    if photo == nil then
        logger:trace("photo is nil")
        LrDialogs.message("FindNextGroupPlugin", "une photo doit etre selectionné")
        return
    end
    logger:trace("first photo existe")


    local ecart = PluginInit.currentEcartInMn * 60
    logger:trace("ecart en secondes : " .. ecart)


    logger:trace("recherche premiere photo du group")
    local photofirst = catalog:getTargetPhoto()
    local datephotofirst = getdatephotovideo(photofirst)
    local photolocalidfirst = photofirst.localIdentifier
    infoPhoto(photofirst, "start")


    result = "first"

    while (true) do

        LrSelection.nextPhoto()
        local photonext = catalog:getTargetPhoto()
        local datephotonext = getdatephotovideo(photonext)
        local photolocalidnext = photonext.localIdentifier
        infoPhoto(photonext, "next")

        if photolocalidfirst == photolocalidnext then
            logger:trace("end")
            result = "end"
            break
        end
        --compare date (diff moins ecart minutes)
        local delta = dateconv(datephotonext) - dateconv(datephotofirst)
        logger:trace("delta '" .. delta .. "'")
        if delta < 0 then -- il y a un pb de boucle possible
            logger:trace("first end delta < 0")
            result = "end"
            break
        end
        if delta < ecart then
            logger:trace("dt-ecart")
            result = "dt-ecart"
            break
        end

        photofirst = photonext
        datephotofirst = datephotonext
        photolocalidfirst = photolocalidnext
    end

    if result == "end" then
        logger:trace("EXIT")
        return
    end

    logger:trace("reselection premier photo")
    LrSelection.previousPhoto()
    infoPhoto(photofirst, "first")


    logger:trace("recherche toute les photos du group")
    local arrayphoto = {}
    local i = 0
    local photoprev = catalog:getTargetPhoto()
    local datephotoprev = getdatephotovideo(photoprev)
    local photolocalidprev = photoprev.localIdentifier
    infoPhoto(photoprev, "last")

    result = "last"

    while (true) do

        LrSelection.nextPhoto()
        local photonext = catalog:getTargetPhoto()
        local datephotonext = getdatephotovideo(photonext)
        local photolocalidnext = photonext.localIdentifier

        if photolocalidprev == photolocalidnext then
            logger:trace("end")
            result = "end"
            break
        end
        --compare date (diff moins ecart minutes)
        local delta = dateconv(datephotonext) - dateconv(datephotoprev)
        logger:trace("delta '" .. delta .. "'")
        if delta < 0 then -- il y a un pb de boucle possible
            logger:trace("last end delta < 0")
            result = "end"
            break
        end
        if delta < ecart then
            logger:trace("dt-ecart")
            i = i + 1
            arrayphoto[i] = photonext
            infoPhoto(photonext, "arrayphoto [" .. i .. "]")
        else
            result = "dt+ecart"
            break
        end

        photoprev = photonext
        datephotoprev = datephotonext
        photolocalidprev = photolocalidnext
    end

    logger:trace("selection")
    catalog:setSelectedPhotos(photofirst, arrayphoto)

    logger:trace("EXIT")

    ChoiceBoxactionforselection()

    logger:trace("OUT")
end)

-- procees current photo
function infoPhoto(photo, text)
    local filename = photo:getFormattedMetadata("fileName")
    local datephoto = photo:getFormattedMetadata("dateTimeOriginal")
    if datephoto == nil then
        datephoto = photo:getFormattedMetadata("dateTimeDigitized")
        logger:trace("dateTimeDigitized")
    end
    if datephoto == nil then
        datephoto = photo:getFormattedMetadata("dateTimeOriginalISO8601")
        logger:trace("dateTimeOriginalISO8601")
    end
    if datephoto == nil then
        datephoto = photo:getFormattedMetadata("dateTimeDigitizedISO8601")
        logger:trace("dateTimeDigitizedISO8601")
    end
    if datephoto == nil then
        datephoto = photo:getFormattedMetadata("dateTimeISO8601")
        logger:trace("dateTimeISO8601")
    end
    if datephoto == nil then
        datephoto = photo:getFormattedMetadata("dateTime")
        logger:trace("dateTime")
    end
    logger:trace(text .. " photo's filename is " .. filename)
    logger:trace(text .. " photo's datephoto is " .. datephoto)
end

function getdatephotovideo(photo)
    local dtphoto = photo:getFormattedMetadata("dateTimeOriginal")
    if dtphoto == nil then
        dtphoto = photo:getFormattedMetadata("dateTimeDigitized")
        logger:trace("dateTimeDigitized")
    end
    if dtphoto == nil then
        dtphoto = photo:getFormattedMetadata("dateTimeOriginalISO8601")
        logger:trace("dateTimeOriginalISO8601")
    end
    if dtphoto == nil then
        dtphoto = photo:getFormattedMetadata("dateTimeDigitizedISO8601")
        logger:trace("dateTimeDigitizedISO8601")
    end
    if dtphoto == nil then
        dtphoto = photo:getFormattedMetadata("dateTimeISO8601")
        logger:trace("dateTimeISO8601")
    end
    if dtphoto == nil then
        dtphoto = photo:getFormattedMetadata("dateTime")
        logger:trace("dateTime")
    end
    return dtphoto
end

-- dateconv
function dateconv(datephoto)
    local p = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"
    day, month, year, hour, min, sec = datephoto:match(p)
    offset = os.time() - os.time(os.date("!*t"))
    local dtconv = os.time({ day = day, month = month, year = year, hour = hour, min = min, sec = sec }) + offset
    logger:trace("date '" .. datephoto .. "'" .. " date convertie = " .. dtconv)
    return dtconv
end

function ChoiceBoxactionforselection()
    logger:trace("ChoiceBoxactionforselection")

    refreshChoiceBoxactionforselection()
    local f = LrView.osFactory() --obtain a view factory
    local contents = f:row {
        -- create UI elements
        spacing = f:label_spacing(),
        f:push_button {
            title = "action 1",
            action = function()
                logger:trace("action 1")
            end,
        },
        spacing = f:label_spacing(),
        f:push_button {
            title = "action 2",
            action = function()
                logger:trace("action 2")
            end,
        },
        spacing = f:label_spacing(),
        f:push_button {
            title = "action 3",
            action = function()
                logger:trace("action 3")
            end,
        },
        spacing = f:label_spacing(),
    }
    logger:trace("LrDialogs.presentModalDialog")

    local result = LrDialogs.presentFloatingDialog(-- invoke a dialog box
        _PLUGIN,
        {
            title = "Action a effectuer",
            contents = contents, -- with the UI elements
            selectionChangeObserver = function()
                refreshChoiceBoxactionforselection()
            end,
        })
    --logger:trace("result")
    --logger:trace("result='"..result.."'")
    --if result == 'ok' then -- action button was clicked
    --    LrDialogs.message("ret = '" .. result "'")
    --end
    return
end

function refreshChoiceBoxactionforselection()
    logger:trace("refreshChoiceBoxactionforselection")
end