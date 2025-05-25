-- Q-Sys plugin for BlackMagic VideoHub
-- <https://documents.blackmagicdesign.com/UserManuals/Videohub12GInstallation.pdf?_v=1680591612000>
-- 20231212 v1.0.0 Rod Driscoll<rod@theavitgroup.com.au>
  -- initial version
-- 20240227 v1.1.0 Rod Driscoll<rod@theavitgroup.com.au>
  -- input/output label index start changed from 0 to 1
-- 20250525 v1.1.1 Rod Driscoll<rod@theavitgroup.com.au>
  -- placed dependency functions directly in plugin so there is no need to install dependecies.

PluginInfo = {
  Name = "BlackMagic~VideoHub", -- The tilde here indicates folder structure in the Shematic Elements pane
  Version = "1.1.1",
  Id = "blackmagic-videohub.plugin.1.0.0", -- don't change Id if you want it to overwrite existing plugin (not even version number)
  Description = "Plugin for controlling a BlackMagic VideoHub",
  ShowDebug = true,
  Author = "Rod Driscoll"
}