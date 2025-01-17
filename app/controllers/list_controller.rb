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
    # Joining fts_charts for extra column (labels).
    scope = Chart.joins("join fts_charts on charts.id = fts_charts.id").joins(:song)
    if (@sorts & ["jrating", "-jrating", "srlevel", "-srlevel"]).any? || @srlevel.present?
      scope = scope.joins(:jkwiki_chart)
    end

    scope = scope.where("songs.debut = ?", @debut) if @debut
    scope = scope.where("songs.debut != 'cslively'") if @lively == "exclude"

    if @omni == "only"
      scope = scope.where("extra like '% omnimix% '")
    elsif @omni == "exclude"
      scope = scope.where("extra not like '% omnimix %'")
    end

    if @folder
      if @folder == "cs" || @folder.to_i.positive?
        scope = scope.where("songs.version_folder = ?", @folder)
      elsif Song::CATEGORIES_BIT_VALUES.include?(@folder)
        scope = scope.where("songs.categories & ? != 0", Song::CATEGORIES_BIT_VALUES[@folder])
      end
    end

    scope = scope.where(difficulty: @diff) if @diff
    scope = scope.where(hardest: true) if @hardest == "1"
    scope = scope.where(level: Numbers.parse_vals_and_ranges(@level, min: 1, max: 50)) if @level.present?
    scope = scope.where(bpm_main: Numbers.parse_vals_and_ranges(@bpm, min: 1, max: 1000)) if @bpm.present?
    scope = scope.where(bpm_main_type: @bpmtype) if @bpmtype.present?
    scope = scope.where(duration: Numbers.parse_vals_and_ranges(@duration, min: 0, max: 599)) if @duration.present?
    scope = scope.where(notes: Numbers.parse_vals_and_ranges(@notes, min: 1, max: 4000)) if @notes.present?
    scope = scope.where(hold_notes: Numbers.parse_vals_and_ranges(@hnotes, min: 0, max: 1000)) if @hnotes.present?
    scope = scope.where("jkwiki_charts.sran_level" => SranLevel.parse_vals_and_ranges(@srlevel, min: "0", max: "20")) if @srlevel.present?
    scope = scope.where(timing: @timing) if @timing.present?

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
        scope = scope.order("songs.r_title #{"desc" if desc}")
      when "rgenre"
        scope = scope.order(Arel.sql("songs.r_genre collate nocase #{"desc" if desc}"))
      when "debut"
        scope = scope.order(Arel.sql("#{DEBUT_ORDER_BY} #{"desc" if desc}"))
      when "id"
        scope = scope.order("songs.id #{"desc" if desc}")
      when "level"
        scope = scope.order("level #{"desc" if desc}")
      when "bpm"
        scope = scope.order("bpm_main #{"desc" if desc}")
      when "duration"
        scope = scope.order("duration #{"desc" if desc}")
      when "notes"
        scope = scope.order("notes #{"desc" if desc}")
      when "hnotes"
        scope = scope.order("hold_notes #{"desc" if desc}")
      when "jrating"
        scope = scope.order("jkwiki_charts.rating_num #{"desc" if desc}")
      when "srlevel"
        scope = scope.order("jkwiki_charts.sran_level #{"desc" if desc}")
      end
    end

    if @q
      token_string = Query.normalize(@q)
      scope = scope.search(token_string, join: false)
    end

    @pagy, @records = pagy(scope)

    render json: {
      data: ChartBlueprint.render_as_hash(@records, view: :with_song),
      pagy: pagy_metadata(@pagy),
    }
  end

  def songs
    parse_params
    # This join is used for level and omni.
    scope = Song.joins("inner join fts_songs on songs.id = fts_songs.id")

    if @folder
      if @folder == "cs" || @folder.to_i.positive?
        scope = scope.where(version_folder: @folder)
      elsif Song::CATEGORIES_BIT_VALUES.include?(@folder)
        scope = scope.where("categories & ? != 0", Song::CATEGORIES_BIT_VALUES[@folder])
      end
    end

    if @level
      where_clause = Level.to_songs_where_clause(@level)
      scope = scope.where(where_clause) if where_clause.present?
    end

    scope = scope.where(debut: @debut) if @debut
    scope = scope.where("songs.debut != 'cslively'") if @lively == "exclude"

    # Note the space between the first % and omnimix.
    if @omni == "only"
      scope = scope.where("extra like '% omnimix %'")
    elsif @omni == "exclude"
      scope = scope.where("extra not like '% omnimix %'")
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
        scope = scope.order("r_title #{"desc" if desc}")
      when "rgenre"
        scope = scope.order(Arel.sql("r_genre collate nocase #{"desc" if desc}"))
      when "debut"
        scope = scope.order(Arel.sql("#{DEBUT_ORDER_BY} #{"desc" if desc}"))
      when "id"
        scope = scope.order("id #{"desc" if desc}")
      end
    end

    if @q
      token_string = Query.normalize(@q)
      # Don't join since we already joined at the beginning.
      scope = scope.search(token_string, join: false)
    end

    @pagy, @records = pagy(scope)

    render json: {
      data: SongBlueprint.render_as_hash(@records, view: :with_charts),
      pagy: pagy_metadata(@pagy),
    }
  end

  private

  def parse_params
    # Charts and songs
    @folder = params[:folder].presence
    @level = params[:level].presence
    @debut = params[:debut].presence
    @omni = params[:omni].presence
    @lively = params[:lively].presence
    @q = params[:q].presence
    @sorts = [params[:sort]].flatten.compact
    @sorts = ["title"] if @sorts.empty?

    # Charts-specific
    @diff = params[:diff].presence || params[:difficulty].presence
    @hardest = params[:hardest].presence
    @bpm = params[:bpm].presence
    @bpmtype = params[:bpmtype].presence
    @duration = params[:duration].presence
    @notes = params[:notes].presence
    @hnotes = params[:hnotes].presence
    @srlevel = params[:srlevel].presence
    @timing = params[:timing].presence
  end
end
