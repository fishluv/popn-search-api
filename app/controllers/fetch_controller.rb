class FetchController < ApplicationController
  def charts
    render json: ChartBlueprint.render(Chart.find(params[:id]))
  end

  def songs
    render json: SongBlueprint.render(Song.find(params[:id]))
  end
end
