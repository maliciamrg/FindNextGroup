-- https://app.assembla.com/wiki/show/lrdevplugin/(Mac-Win)_IntelliJ_and_LUA
--

return {
  VERSION = { display="202012280208" },
 
  LrSdkVersion = 9.0,
  LrSdkMinimumVersion = 4.0,
 
  LrToolkitIdentifier = "com.maliciamrg.hello",
  LrPluginName = "FindNextGroup",
  LrPluginInfoUrl="http://www.daisy-street.fr/wordpress/android/",

  LrPluginInfoProvider = 'PluginInfoProvider.lua',
  LrInitPlugin = 'PluginInit.lua',

  LrExportMenuItems = { title = 'My &Plugin', file = 'somefile.lua' },  -- File menu
  LrLibraryMenuItems = { title = '&Workflow New', file = 'findnextgroup.lua' }, -- Library menu
  LrHelpMenuItems = { title = 'My &Plugin', file = 'somefile.lua' },    -- Help menu
}
