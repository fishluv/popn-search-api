class FetchController < ApplicationController
  def charts
    # `ex` must come before `e`, or else `e` will shadow `ex`.
    slug, diff = params[:slug_diff].match(/^(.*)-(ex|e|n|h)$/)&.[](1..2)
    unless slug.present? && diff.present?
      raise ActionController::BadRequest, "expected param of form \"<slug>-{e|n|h|ex}\""
    end

    song = Song.find_by!(slug: slug)
    chart = song&.charts&.find { _1.difficulty == diff }
    raise ActiveRecord::RecordNotFound unless chart

    render json: ChartBlueprint.render(chart)
  end

  def charts_v2
    song = Song.find_by!(slug: params[:slug])
    chart = song&.charts&.find { _1.difficulty == params[:diff] }
    raise ActiveRecord::RecordNotFound unless chart

    render json: ChartV2Blueprint.render(chart, view: :with_song)
  end
end
