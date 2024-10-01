class ListController < ApplicationController
  def charts
    parse_params
    scope = Chart.joins(:song)
    scope = scope.where("songs.debut = ?", @debut) if @debut.presence
    scope = scope.where("songs.folder = ?", @folder) if @folder.presence
    scope = scope.where(difficulty: @diff) if @diff.presence
    scope = scope.where(level: @level) if @level.presence

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
        scope = scope.order("songs.debut #{"desc" if desc}")
      when "folder"
        scope = scope.order("songs.folder #{"desc" if desc}")
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
    scope = scope.where(folder: @folder) if @folder

    if @level
      where_clause = Level.to_where_clause(@level)
      scope = scope.joins("inner join fts_songs on songs.id = fts_songs.id")
                   .where(where_clause)
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
        scope = scope.order("debut #{"desc" if desc}")
      when "folder"
        scope = scope.order("folder #{"desc" if desc}")
      when "id"
        scope = scope.order("id #{"desc" if desc}")
      end
    end

    if @q
      token_string = Query.normalize(@q)
      scope = scope.search(token_string)
    end

    @pagy, @records = pagy(scope)

    render json: {
      data: SongBlueprint.render_as_hash(@records, view: :with_charts),
      pagy: pagy_metadata(@pagy),
    }
  end

  private

  def parse_params
    @debut = params[:debut]
    @folder = params[:folder]
    @diff = params[:diff]
    @level = params[:level]
    @sorts = [params[:sort]].flatten.compact
    @sorts = ["title"] if @sorts.empty?
    @q = params[:q].presence
  end
end
