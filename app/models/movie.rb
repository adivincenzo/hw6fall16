class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NR)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
def self.find_in_tmdb(string)
  Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
  begin
    matching_movies = Tmdb::Movie.find(string)
    
    if matching_movies == nil
      matching_movies = []
      return matching_movies
    else
      results = []
      matching_movies.each do |movie_match|
        rating = Movie.find_rating(movie_match.id)
        results.push({tmdb_id: movie_match.id, title: movie_match.title, rating: rating, release_date: movie_match.release_date, description: Tmdb::Movie.detail(movie_match.id)['overview']})
      end
      return results
    end
    
  rescue Tmdb::InvalidApiKeyError
    raise Movie::InvalidKeyError, 'Invalid API key'
  end
end

def self.find_rating(id)
  release_data = Tmdb::Movie.releases(id)
  countries = release_data['countries']
  
  if countries != nil
    ratings = countries.find_all{|movie| movie['iso_3166_1'] == 'US'}
    #puts(ratings)
    if ratings != nil
      ratings.each do |rating|
        if(self.all_ratings.include?(rating['certification']))
          return rating['certification']
        end
      end
      return 'NR'
    else
      return ''
    end
  end
  
end

def self.create_from_tmdb(id)
  begin
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    deets = Tmdb::Movie.detail(id)
    Movie.create!(title: deets['title'], description: deets['overview'], rating: find_rating(id), release_date: deets['release_date'] )
  
  rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
  end
  
end

end
