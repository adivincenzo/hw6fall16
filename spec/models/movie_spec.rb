require 'spec_helper'
require 'rails_helper'

describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
      it 'should return an empty array if the Tmdb does not contain the search term' do
        expect(Tmdb::Movie).to receive(:find).with('xxxxxx').and_return(nil)
        output = Movie.find_in_tmdb('xxxxxx')
        expect(output).to eq([])
      end
      it 'should parse the information from tmdb correctly' do
        movie = [Tmdb::Movie.new({id:1, title: 'Inception', release_date: '2010-07-14'})]
          
        expect(Tmdb::Movie).to receive(:find).with('Inception').and_return(movie)
        allow(Tmdb::Movie).to receive(:detail).with(1).and_return({'overview' => 'description'})
        allow(Movie).to receive(:find_rating).with(1).and_return('PG-13')
        output = Movie.find_in_tmdb('Inception')
          
        expect(output.count).to eq(1)
        expect(output[0][:tmdb_id]).to eq(1)
        expect(output[0][:rating]).to eq('PG-13')
        expect(output[0][:title]).to eq('Inception')
        expect(output[0][:description]).to eq('description')
        expect(output[0][:release_date]).to eq('2010-07-14')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  describe 'adding movie from Tmdb' do
    context 'with valid key' do
      before :each do
        expect(Tmdb::Movie).to receive(:detail).with(1).and_return({'overview' => 'description', 'release_date' => '2010-07-14', 'title' => 'Inception'})
      end
      it 'should correctly parse the information from tmdb' do
        expect(Movie).to receive(:find_rating).with(1).and_return('PG-13')
        output = Movie.create_from_tmdb(1)
        
        expect(output[:rating]).to eq('PG-13')
        expect(output[:title]).to eq('Inception')
        expect(output[:description]).to eq('description')
        expect(output[:release_date]).to eq('2010-07-14')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:detail).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.create_from_tmdb(1) }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  describe 'find rating' do
    it 'should return a rating for movies released in the US' do
      expect(Tmdb::Movie).to receive(:releases).with(1).and_return({'iso_3166_1' => 'US'})
      rating = Movie.find_rating(1)
      expect(rating).to eq(nil)
    end
    
  end
  
  describe 'all ratings' do
    it 'should contain all ratings applicable to movies stored in Rotten Potatoes' do
      expect(Movie.all_ratings[0]).to eq('G')
      expect(Movie.all_ratings[1]).to eq('PG') 
      expect(Movie.all_ratings[2]).to eq('PG-13') 
      expect(Movie.all_ratings[3]).to eq('NC-17') 
      expect(Movie.all_ratings[4]).to eq('R') 
      expect(Movie.all_ratings[5]).to eq('NR') 
      
    end
  end
  
end
