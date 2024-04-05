{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit laz_gitwizard;

{$warn 5023 off : no warning about unused units}
interface

uses
  gitwizard, gw_frame, newcommand, input_form, options_form, gw_rsstrings, 
  move_button, info_form, output_form, newtab, move_toatab, new_properties, 
  new_tabproperties, gw_highlighter, argument_dialog, edit_arguments, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('gitwizard', @gitwizard.Register);
end;

initialization
  RegisterPackage('laz_gitwizard', @Register);
end.
