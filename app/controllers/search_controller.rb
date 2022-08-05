class SearchController < ApplicationController
  PERTINENT_SONG_COLUMNS_AND_WEIGHTS = {
    "title" => 1,
    "remywiki_title" => 1,
    "genre" => 1,
    "genre_romantrans" => 1,
    "artist" => 1,
  }.freeze
  PERTINENT_SONG_COLUMNS = PERTINENT_SONG_COLUMNS_AND_WEIGHTS.keys.freeze

  def charts
    @raw_query = params[:q].presence&.chomp
    return render json: [] unless @raw_query

    tokenize_and_normalize
    parse_difficulty_and_level
    @token_string = @tokens.join(" ")

    base_eligible_clause = "#{PERTINENT_SONG_COLUMNS.join(" || ' ' || ")} like '%#{@token_string}%'"
    diff_clause = @difficulty ? { difficulty: @difficulty } : {}
    level_clause = @level ? { level: @level } : {}
    eligible =
      Chart
        .where(song: Song.where(base_eligible_clause))
        .where(diff_clause)
        .where(level_clause)
        .limit(50)
    results = eligible.sort { |a, b| chart_score(b) <=> chart_score(a) }.first(8)

    if params.key?(:debug)
      Rails.logger.info "difficulty: #{@difficulty.inspect}"
      Rails.logger.info "level: #{@level.inspect}"
      Rails.logger.info "tokens: #{@tokens}"
      Rails.logger.info "results:"
      results.each { |r| Rails.logger.info "  #{chart_score(r)} #{r}" }
    end

    render json: ChartBlueprint.render(results)
  end

  def songs
    @raw_query = params[:q].presence&.chomp
    return render json: [] unless @raw_query

    tokenize_and_normalize
    parse_difficulty_and_level
    @token_string = @tokens.join(" ")

    base_eligible_clause = "#{PERTINENT_SONG_COLUMNS.join(" || ' ' || ")} like '%#{@token_string}%'"
    diff_level_clause =
      if @difficulty && @level
        { level_column_from_diff => @level }
      else
        {}
      end
    eligible = Song.where(base_eligible_clause).where(diff_level_clause).limit(30)
    results = eligible.sort { |a, b| song_score(b) <=> song_score(a) }.first(8)

    if params.key?(:debug)
      Rails.logger.info "difficulty: #{@difficulty.inspect}"
      Rails.logger.info "level: #{@level.inspect}"
      Rails.logger.info "tokens: #{@tokens}"
      Rails.logger.info "results:"
      results.each { |r| Rails.logger.info "  #{song_score(r)} #{r}" }
    end

    render json: SongBlueprint.render(results)
  end

  private

  def tokenize_and_normalize
    @tokens = @raw_query.split(/\s+/).map(&:downcase)
  end

  def parse_difficulty_and_level
    diff = @tokens.find { |t| %w[e easy n normal h hyper ex].include?(t) }
    lvl = @tokens.find { |t| t.match?(/^\d{1,2}$/) }

    @difficulty = @tokens.delete(diff) if diff

    lvl_int = lvl&.to_i
    if (1..50).include?(lvl_int)
      @tokens.delete(lvl)
      @level = lvl_int
    end
  end

  def level_column_from_diff
    case @difficulty
    when "e", "easy"
      :easy_diff
    when "n", "normal"
      :normal_diff
    when "h", "hyper"
      :hyper_diff
    when "ex"
      :ex_diff
    else
      nil
    end
  end

  def chart_score(chart)
    score = 0
    PERTINENT_SONG_COLUMNS_AND_WEIGHTS.each do |col, weight|
      c = chart.song[col].downcase
      if @token_string.include?(c) || c.include?(@token_string)
        score += weight
      end
    end
    score += diff_score(chart.difficulty)
    score
  end

  def diff_score(diff)
    case diff
    when "ex"
      0.3
    when "h"
      0.2
    when "n"
      0.1
    else
      0
    end
  end

  def song_score(song)
    score = 0
    PERTINENT_SONG_COLUMNS_AND_WEIGHTS.each do |col, weight|
      c = song[col].downcase
      if @token_string.include?(c) || c.include?(@token_string)
        score += weight
      end
    end
    score
  end
end
