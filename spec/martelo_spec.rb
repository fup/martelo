describe Martelo do
  include Rack::Test::Methods

  def app
    @app ||= Martelo::App
  end

  let(:hostname) { 'puppet.us.chstest.net' }
  let(:address) { '10.5.176.158' }

  describe "happy path" do
    it '/ should return a basic website' do
      get "/"
      last_response.body.should_not be_empty
    end

    it '/ should return a redirect to the correct hostname if the useragent is ananconda' do
      get "/"
    end

    it '/hostname should return a kickstart file' do
      kickstart = File.join(File.dirname(__FILE__),"fixtures/#{hostname}.ks")
      get "/#{hostname}"
      last_response.should be_ok
      gen_kickstart = StringIO.new(last_response.body)
      File.open(kickstart) { |f| f.read.should == gen_kickstart.read }
    end
  end

  describe 'errors' do
    it 'should return 404 when a server does not exist in dns' do
      get '/floopity.bloopity.bloo'
      last_response.status.should eql(404)
    end
    it 'should return 404 when an app does not exist' do
      get "/#{hostname}/bloopitybloo"
      last_response.status.should eql(404)
    end

    it 'should error on a malformed hostname' do
      get "/www...google.com"
      last_response.status.should eql(404)
    end
  end
end
