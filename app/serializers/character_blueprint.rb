class CharacterBlueprint < Blueprinter::Base
  identifier :id

  fields *%i[
    chara_id
    icon1
    disp_name
    romantrans_name
  ]

  field :sort_char do |character|
    character.sort_name[0]
  end
end
