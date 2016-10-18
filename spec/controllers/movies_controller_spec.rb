require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    it 'should check for invalid search terms' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => ''}
      expect(flash[:warning]).to eq('Invalid search term')
      expect(response).to redirect_to '/movies' 
    end
    it 'should make the search terms available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'hi'}
      expect(assigns(:search_terms)).to eq('hi')
    end
    it 'should show no movies match if nothing is found on TMDb' do
      post :search_tmdb, {:search_terms => 'xxxxxx'}
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      expect(response).to redirect_to(movies_path)
      expect(flash[:warning]).to eq("No matching movies were found on TMDb")
    end
  end
  describe 'adding TMDb movies' do
    before :each do
      @fake_results = [double('moviex'), double('moviey')]
    end
    it 'should return to the movies page if nothing was selected' do
      post :add_tmdb, {}
      expect(flash[:warning]).to eq("No movies were added")
      expect(response).to redirect_to(movies_path)
    end
    it 'should call the model method that creates Tmdb Movie' do
      expect(Movie).to receive(:create_from_tmdb).with("555")
      expect(Movie).to receive(:create_from_tmdb).with("777")
      post :add_tmdb, {"tmdb_movies" => {"555" => "1", "777" => "1"}}
      expect(flash[:notice]).to eq("Movies successfully added to Rotten Potatoes")
    end
    
  end

  
end
