class SearchController < ApplicationController
  def charts
    raw_query = params[:q].presence&.chomp
    return render json: [] unless raw_query

    limit = params[:limit].to_i
    limit = 10 if limit == 0
    limit = 25 if limit > 25

    token_string = Query.normalize(raw_query)
    results = Chart.search(token_string).limit(limit)

    render json: ChartBlueprint.render(results, view: :with_song)
  end

  def songs
    raw_query = params[:q].presence&.chomp
    return render json: [] unless raw_query

    limit = params[:limit].to_i
    limit = 10 if limit == 0
    limit = 25 if limit > 25

    token_string = Query.normalize(raw_query)
    results = Song.search(token_string).limit(limit)

    render json: SongBlueprint.render(results, view: :with_charts)
  end
end
