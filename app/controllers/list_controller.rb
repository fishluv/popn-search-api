class ListController < ApplicationController
  DEBUT_ORDER_BY = %(
    case cast(songs.debut as integer)
    when 0 then -- non-ac version --
      case cast(replace(songs.debut, 'cs', '') as integer)
      when 0 -- non-numbered cs version (and eemall) --
        then
          case songs.debut
          when 'csbest' then '007b'
          when 'cspmp' then '016'
          when 'csutacchi' then '017'
          when 'cspmp2' then '018'
          when 'cslively' then '019'
          when 'eemall' then '109e'
          end
      else '0' || substr('0' || replace(songs.debut, 'cs', ''), -2, 2) -- sort cs before ac --
      end
    else '1' || substr('0' || songs.debut, -2, 2)
    end
  )

  def charts
    parse_params
    scope = Chart.joins(:song)
    scope = scope.where("songs.debut = ?", @debut) if @debut

    if @folder
      if @folder == "cs" || @folder.to_i.positive?
        scope = scope.where("songs.version_folder = ?", @folder)
      elsif Song::CATEGORIES_BIT_VALUES.include?(@folder)
        scope = scope.where("songs.categories & ? != 0", Song::CATEGORIES_BIT_VALUES[@folder])
      end
    end

    scope = scope.where(difficulty: @diff) if @diff

    parsed_levels = Numbers.parse_nums_and_ranges(@level, min: 1, max: 50)
    scope = scope.where(level: parsed_levels) if @level.present?

    parsed_bpm = Numbers.parse_nums_and_ranges(@bpm, min: 1, max: 999)
    Rails.logger.error "#{@bpm}, #{parsed_bpm}"

    scope = scope.where(bpm_primary: parsed_bpm) if @bpm.present?

    @sorts.each do |sort|
      desc = sort.start_with?("-")
      sort.delete_prefix!("-")
      # Don't forget `collate nocase` (for columns that need it).
      case sort
      when "title"
        scope = scope.order("songs.fw_title #{"desc" if desc}")
      when "genre"
        scope = scope.order("songs.fw_genre #{"desc" if desc}")
      when "rtitle"
        scope = scope.order("songs.remywiki_title #{"desc" if desc}")
      when "rgenre"
        scope = scope.order(Arel.sql("songs.genre_romantrans collate nocase #{"desc" if desc}"))
      when "debut"
        scope = scope.order(Arel.sql("#{DEBUT_ORDER_BY} #{"desc" if desc}"))
      when "id"
        scope = scope.order("songs.id #{"desc" if desc}")
      when "level"
        scope = scope.order("level #{"desc" if desc}")
      end
    end

    if @q
      token_string = Query.normalize(@q)
      scope = scope.search(token_string)
    end

    @pagy, @records = pagy(scope)

    render json: {
      data: ChartBlueprint.render_as_hash(@records, view: :with_song),
      pagy: pagy_metadata(@pagy),
    }
  end

  def songs
    parse_params
    scope = Song
    scope = scope.where(debut: @debut) if @debut

    if @folder
      if @folder == "cs" || @folder.to_i.positive?
        scope = scope.where(version_folder: @folder)
      elsif Song::CATEGORIES_BIT_VALUES.include?(@folder)
        scope = scope.where("categories & ? != 0", Song::CATEGORIES_BIT_VALUES[@folder])
      end
    end

    if @level
      where_clause = Level.to_songs_where_clause(@level)
      if where_clause.present?
        scope = scope.joins("inner join fts_songs on songs.id = fts_songs.id")
                    .where(where_clause)
      end
    end

    @sorts.each do |sort|
      desc = sort.start_with?("-")
      sort.delete_prefix!("-")
      # Don't forget `collate nocase` (for columns that need it).
      case sort
      when "title"
        scope = scope.order("fw_title #{"desc" if desc}")
      when "genre"
        scope = scope.order("fw_genre #{"desc" if desc}")
      when "rtitle"
        scope = scope.order("remywiki_title #{"desc" if desc}")
      when "rgenre"
        scope = scope.order(Arel.sql("genre_romantrans collate nocase #{"desc" if desc}"))
      when "debut"
        scope = scope.order(Arel.sql("#{DEBUT_ORDER_BY} #{"desc" if desc}"))
      when "id"
        scope = scope.order("id #{"desc" if desc}")
      end
    end

    if @q
      token_string = Query.normalize(@q)
      # This joins fts_songs. Don't join if we already joined for level above.
      scope = scope.search(token_string, join: @level.blank?)
    end

    @pagy, @records = pagy(scope)

    render json: {
      data: SongBlueprint.render_as_hash(@records, view: :with_charts),
      pagy: pagy_metadata(@pagy),
    }
  end

  private

  def parse_params
    @debut = params[:debut].presence
    @folder = params[:folder].presence
    @diff = params[:diff].presence
    @level = params[:level].presence
    @sorts = [params[:sort]].flatten.compact
    @sorts = ["title"] if @sorts.empty?
    @q = params[:q].presence

    # Charts-specific
    @bpm = params[:bpm].presence
  end
end
