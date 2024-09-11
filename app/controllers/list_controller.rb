class ListController < ApplicationController
  def charts
    parse_params
    results = Chart
    results = results.where(difficulty: @diff) if @diff
    results = results.where(level: @level) if @level
    results = results.limit(100)

    render json: ChartBlueprint.render(results, view: :with_song)
  end

  def songs
    parse_params
    results = Song
    results = results.where(debut: @debut) if @debut
    results = results.where(folder: @folder) if @folder
    results = results.limit(100)

    render json: SongBlueprint.render(results, view: :with_charts)
  end

  private

  def parse_params
    @debut = params[:debut]
    @folder = params[:folder]
    @diff = params[:diff]
    @level = params[:level]
  end
end
