class SearchController < ApplicationController
  def all
    songs
  end

  def songs
    render json: Song.first(5)
  end
end
