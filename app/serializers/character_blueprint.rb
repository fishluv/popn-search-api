class CharacterBlueprint < Blueprinter::Base
  identifier :id

  fields *%i[
    chara_id
    icon1
    sort_name
    disp_name
  ]
end
