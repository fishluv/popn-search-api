class CharacterBlueprint < Blueprinter::Base
  identifier :id

  fields *%i[
    chara_id
    icon1
    disp_name
    romantrans_name
    sort_char
  ]
end
