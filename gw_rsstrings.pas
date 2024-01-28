{This is a part of GitWizard}
unit gw_rsstrings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

resourcestring
  rs_comnotfound                      = 'Command-File not found!';
  rs_comerror                         = 'The command is incorrect!';
  rs_ignorenofound                    = 'Default gitignore not found!';
  rs_nodirectoryselected              = 'No directory selected!';
  rs_Filealreadyexists                = 'File already exists!';
  rs_filenotfound                     = 'File not found!';
  rs_Directorynotfound                = 'Directory not found!';
  rs_checkoptionsdialog               = 'Please check optionsdialog!';
  rs_gw_commands                      = 'File not found: gw_commands.xml!';
  rs_AnyDirHint                       = 'Set Any Directory';
  rs_LastSavedProject                 = 'Set Last Saved Project-Directory';
  rs_LastSavePackage                  = 'Set open Package-Directory';
  rs_defgitignore                     = 'Edit default gitignore';
  rs_newCommand                       = 'Create a new command';
  rs_opendir                          = 'Open set Directory';
  rs_options                          = 'Options';
  rs_createbackup                     = 'Create a Backup of Commands';
  rs_createnewbackup                  = 'Do you want to create a new backup? All old files in the backup folder are deleted!';
  rs_restorebackup                    = 'Restore backup';
  rs_restorebackuptext                = 'Would you like to load the data from the last backup? All old files in the command folder are deleted!';
  rs_Info                             = 'Info';
  rs_openfile                         = 'Open File';
  rs_deletecommand                    = 'Delete command';
  rs_movebutton                       = 'Move Button';
  rs_movetotab                        = 'Move to another tab';
  rs_error                            = 'Error';
  rs_yes                              = 'Yes';
  rs_no                               = 'No';
  rs_forcommans                       = 'Edit for single commands';
  rs_excecute                         = 'Excecute';
  rs_moreopen                         = 'There are several packages open!';
  rs_favorites                        = 'Favorites';
  rs_newtab                           = 'Creates a new tab';

  rs_newcommandform                   = 'New Command Dialog';
  rs_nocaption                        = 'No caption entered';
  rs_nofilename                       = 'No filename entered';
  rs_nocommand                        = 'No command entered';

  rs_Optionsform                      = 'Options';
  rs_selectEditor                     = 'Select an editor:';

  rs_EnterACaption                    = 'Please enter a caption for the new button:';
  rs_EnterAFilename                   = 'Please enter a filename for the new bash:';
  rs_EnterACommand                    = 'Please enter a new command:';
  rs_EnterAHint                       = 'Please enter a hint for the new button:';
  rs_Cancel                           = 'Cancel';
  rs_NeedInput                        = 'The command requires an input';

  rs_InputForm                        = 'Complete the command dialog';
  rs_CopleteCommand                   = 'Complete the command:';

  rs_NewPos                           = 'New Position:';
  rs_EnterNewPos                      = 'Enter a new position!';

  rs_InfoLine1                        = 'GitWizard integrates the operation of git into the Lazarus IDE.';
  rs_InfoLine2                        = 'Commands are called via scripts that can be created or changed by the user.';
  rs_InfoLine3                        = 'License: GNU General Public License (GNU GPL)';
  rs_InfoLine4                        = 'All icons from Roland Hahn. Thank you very mutch!';

  rs_movetoatab                       = 'Move a button to a new tabsheet';
  rs_selectanewtab                    = 'Select a new tabsheet:';

implementation

end.

