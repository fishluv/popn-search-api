class SearchController < ApplicationController
  def charts
    @raw_query = params[:q].presence&.chomp
    return render json: [] unless @raw_query

    limit = params[:limit].to_i
    limit = 10 if limit == 0
    limit = 25 if limit > 25

    tokenize_and_normalize
    pad_difficulty_and_numbers
    token_string = @tokens.join(" ")
    results = Chart.search(token_string).limit(limit)

    if params[:version] == "v2"
      render json: ChartV2Blueprint.render(results, view: :search)
    else
      render json: ChartBlueprint.render(results)
    end
  end

  def songs
    @raw_query = params[:q].presence&.chomp
    return render json: [] unless @raw_query

    limit = params[:limit].to_i
    limit = 10 if limit == 0
    limit = 25 if limit > 25

    tokenize_and_normalize
    pad_difficulty_and_numbers
    token_string = @tokens.join(" ")
    results = Song.search(token_string).limit(limit)

    if params[:version] == "v2"
      render json: SongV2Blueprint.render(results, view: :search)
    else
      render json: SongBlueprint.render(results)
    end
  end

  private

  def tokenize_and_normalize
    @tokens = @raw_query.split(/\s+/).map(&:downcase)
  end

  def pad_difficulty_and_numbers
    diff = @tokens.find { %w[e n h ex].include?(_1) }
    if diff
      @tokens.delete(diff)
      @tokens << norm_diff(diff).rjust(3, "_")
    end

    @tokens
      .select { _1.match?(/^\d{1,2}$/) }
      .each do |t|
        @tokens.delete(t)
        @tokens << t.rjust(3, "_")
      end
  end

  def norm_diff(diff)
    case diff
    when "e"
      "easy"
    when "n"
      "normal"
    when "h"
      "hyper"
    else
      diff
    end
  end
end
