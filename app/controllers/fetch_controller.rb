class FetchController < ApplicationController
  def charts
    song = Song.find_by!(slug: params[:slug])
    chart = song&.charts&.find { _1.difficulty == params[:diff] }
    raise ActiveRecord::RecordNotFound unless chart

    render json: ChartBlueprint.render(chart, view: :with_song_and_other_charts)
  end
end
