local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrSelection = import 'LrSelection'


local LrLogger = import 'LrLogger'
local logger = LrLogger('FindNextGroupPlugin')
logger:enable("logfile")
 
LrTasks.startAsyncTask(function ()
  local catalog = LrApplication.activeCatalog()
  logger:trace("START")

  local datephotoprev = ""
  while (processPhoto(catalog,datephotoprev) == false ) do
    --recherche premiere photo du group
    local photo = catalog:getTargetPhoto()
    datephotoprev= photo:getFormattedMetadata("dateTime")
    LrSelection.nextPhoto()

    logger:trace("tst")
    return

  end

  LrSelection.previousPhoto()
  local photodebgroup = catalog:getTargetPhoto()
  datephotoprev= photodebgroup:getFormattedMetadata("dateTime")

  while (processPhoto(catalog,datephotoprev) == true ) do
    --recherche premiere photo du group
    local photo = catalog:getTargetPhoto()
    datephotoprev= photo:getFormattedMetadata("dateTime")
    LrSelection.nextPhoto()

    logger:trace("tst")
    return

  end

  LrSelection.previousPhoto()
  local photofingroup = catalog:getTargetPhoto()

end)

-- procees current photo
function processPhoto(catalog,datephotoprev)
  local photo = catalog:getTargetPhoto()
  if photo == nil then
    LrSelection.selectFirstPhoto()
    return false
  end
  local filename = photo:getFormattedMetadata("fileName")
  local datephoto = photo:getFormattedMetadata("dateTime")
  local msg = string.format("The selected photo's datephoto is %q", datephoto)

  LrDialogs.message("FindNextGroupPlugin", msg)
  logger:trace("The selected photo's filename is ", filename)
  logger:trace("The selected photo's datephoto is ", datephoto)

--compare date (diff moins 30 minutes)
  return true
end