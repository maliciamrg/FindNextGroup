--
-- Created by IntelliJ IDEA.
-- User: professorX
-- Date: 28/12/2020
-- Time: 01:13
-- To change this template use File | Settings | File Templates.
--

require "PluginInit"

local function sectionsForBottomOfDialog( f, _ )
    return {
        -- Section for the top of the dialog.
        {
            title = "Custom Plugin Info",
            f:row {
                f:static_text {
                    title = "Global default value for Ecart_In_Min:",
                },
                f:edit_field {
                    title = "Ecart_In_Min:",
                    value = PluginInit.currentEcartInMn,
                    min = 1,
                    max = 120,
                    precision = 0,
                    validate = function(view, value)
                        if value ~= nil and type(value) == 'number' then
                            PluginInit.currentEcartInMn = value
                            return true, value
                        end
                        return false, PluginInit.currentEcartInMn, 'value for Ecart_In_Min must be numeric'
                    end
                },
            },
        },

    }
end

return{

    sectionsForBottomOfDialog = sectionsForBottomOfDialog,

}
