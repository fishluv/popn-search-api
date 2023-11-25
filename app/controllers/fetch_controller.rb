class FetchController < ApplicationController
  def charts
    render json: ChartV2Blueprint.render(Chart.find(params[:id]), view: :fetch)
  end

  def songs
    render json: SongV2Blueprint.render(Song.find(params[:id]), view: :fetch)
  end
end
