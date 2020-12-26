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
  local photo = catalog:getTargetPhoto()
  if photo == nil then
    logger:trace("photo is nil")
    LrDialogs.message("FindNextGroupPlugin", "une photo doit etre selectionné")
    return
  end
  logger:trace("photo existe")


  logger:trace("recherche premiere photo du group")
  local photo = catalog:getTargetPhoto()
  local datephotoprev= photo:getFormattedMetadata("dateTimeOriginal")
  local photolocalidprev= photo.localIdentifier
  LrSelection.nextPhoto()

  while (processPhoto(catalog,photolocalidprev,datephotoprev) == ("dt+30" or "end" ) ) do
    --recherche premiere photo du group
    local photo = catalog:getTargetPhoto()
    datephotoprev= photo:getFormattedMetadata("dateTimeOriginal")
    photolocalidprev= photo.localIdentifier
    LrSelection.nextPhoto()
  end
  logger:trace("recherche premiere photo du group --- fin")


  LrSelection.previousPhoto()
  local photodebgroup = catalog:getTargetPhoto()
  local filename = photodebgroup:getFormattedMetadata("fileName")
  local datephotoprev = photodebgroup:getFormattedMetadata("dateTimeOriginal")
  logger:trace("The selected photodebgroup's filename is ", filename)
  logger:trace("The selected photodebgroup's datephoto is ", datephotoprev)


  logger:trace("recherche dernier photo du group")
  local photo = catalog:getTargetPhoto()
  local datephotoprev= photo:getFormattedMetadata("dateTimeOriginal")
  local photolocalidprev= photo.localIdentifier
  LrSelection.nextPhoto()

  while (processPhoto(catalog,photolocalidprev,datephotoprev) == ("dt-30" or "end" ) ) do
--recherche dernier photo du group
    local photo = catalog:getTargetPhoto()
    datephotoprev= photo:getFormattedMetadata("dateTimeOriginal")
    photolocalidprev= photo.localIdentifier
    LrSelection.nextPhoto()
  end
  logger:trace("recherche dernier photo du group --- fin")


  LrSelection.previousPhoto()
  local photofingroup = catalog:getTargetPhoto()
  local filename = photofingroup:getFormattedMetadata("fileName")
  local datephotoprev = photofingroup:getFormattedMetadata("dateTimeOriginal")
  logger:trace("The selected photofingroup's filename is ", filename)
  logger:trace("The selected photofingroup's datephoto is ", datephotoprev)

end)

-- procees current photo
function processPhoto(catalog,photolocalidprev,datephotoprev)

  local photo = catalog:getTargetPhoto()
  local filename = photo:getFormattedMetadata("fileName")
  local datephoto = photo:getFormattedMetadata("dateTimeOriginal")

  logger:trace("The selected photo's filename is ", filename)
  logger:trace("The selected photo's datephoto is ", datephoto)

  local photolocalid= photo.localIdentifier
  if photolocalidprev == photolocalid then
    logger:trace("end")
    return "end"
  end

--compare date (diff moins 30 minutes)
  local delta =  dateconv(datephoto) - dateconv(datephotoprev)
  logger:trace("delta '" .. delta .. "'")
  if delta < 30 then
    logger:trace("dt-30")
    return "dt-30"
  else
    logger:trace("dt+30")
    return "dt+30"
  end

end

-- dateconv
function dateconv(datephoto)
  logger:trace("date '" .. datephoto .. "'")
  local p="(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"
  day,month,year,hour,min,sec=datephoto:match(p)
  offset=os.time()-os.time(os.date("!*t"))
  local dtconv =  os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})+offset
  logger:trace("date convertie ", dtconv)
  return dtconv
end