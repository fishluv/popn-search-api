class SearchController < ApplicationController
  PERTINENT_SONG_COLUMNS_AND_WEIGHTS = {
    "title" => 1,
    "remywiki_title" => 1,
    "genre" => 1,
    "genre_romantrans" => 1,
    "artist" => 1,
  }.freeze
  PERTINENT_SONG_COLUMNS = PERTINENT_SONG_COLUMNS_AND_WEIGHTS.keys.freeze

  def all
    songs
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
    results = eligible.sort { |a, b| song_score(b) <=> song_score(a) }.first(10)

    if params.key?(:debug)
      Rails.logger.info "difficulty: #{@difficulty.inspect}"
      Rails.logger.info "level: #{@level.inspect}"
      Rails.logger.info "tokens: #{@tokens}"
      Rails.logger.info "results:"
      results.each { |r| Rails.logger.info "  #{song_score(r)} #{r}" }
    end

    render json: results
  end

  private

  def tokenize_and_normalize
    @tokens = @raw_query.split(/\s+/).map(&:downcase)
  end

  def parse_difficulty_and_level
    diff = @tokens.find { |t| %w[e easy n normal h hyper ex].include?(t) }
    lvl = @tokens.find { |t| t.match?(/^\d{1,2}$/) }
    if diff && lvl
      @difficulty = @tokens.delete(diff)
      @level = @tokens.delete(lvl)&.to_i
    else
      @difficulty = nil
      @level = nil
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
