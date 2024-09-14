class ListController < ApplicationController
  def charts
    parse_params
    scope = Chart.joins(:song)
    scope = scope.where("songs.debut = ?", @debut) if @debut.presence
    scope = scope.where("songs.folder = ?", @folder) if @folder.presence
    scope = scope.where(difficulty: @diff) if @diff.presence
    scope = scope.where(level: @level) if @level.presence

    @order.each do |order|
      desc = order.start_with?("-")
      order.delete_prefix!("-")
      case order
      when "title"
        scope = scope.order("songs.fw_title #{"desc" if desc}")
      when "genre"
        scope = scope.order("songs.fw_genre #{"desc" if desc}")
      when "rtitle"
        scope = scope.order("songs.remywiki_title #{"desc" if desc}")
      when "id"
        scope = scope.order("songs.id #{"desc" if desc}")
      when "level"
        scope = scope.order("level #{"desc" if desc}")
      end
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

    @order.each do |order|
      desc = order.start_with?("-")
      order.delete_prefix!("-")
      case order
      when "title"
        scope = scope.order("fw_title #{"desc" if desc}")
      when "genre"
        scope = scope.order("fw_genre #{"desc" if desc}")
      when "rtitle"
        scope = scope.order("remywiki_title #{"desc" if desc}")
      when "id"
        scope = scope.order("id #{"desc" if desc}")
      end
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
    @order = [params[:order]].flatten.compact
  end
end
