require 'spec_helper'
require 'spec_fakes'
# require 'active_model'

describe Grape::ActiveModelSerializers do
  subject do
    Class.new(Grape::API)
  end

  before do
    subject.format :json
    subject.formatter :json, Grape::Formatter::ActiveModelSerializers

    ActiveRecord::Base.configurations.merge!('test' => {'adapter' => 'nulldb'})
  end

  def app
    subject
  end

  it "should use the built in grape serializer when serializer is set to nil" do
    subject.get("/home", serializer: nil) do
      {user: {first_name: "JR", last_name: "HE"}}
    end
    get("/home")
    last_response.body.should == "{\"user\":{\"first_name\":\"JR\",\"last_name\":\"HE\"}}"
  end

  it "should respond with proper content-type" do
    subject.get("/home", :serializer => "user") do
      {user: {first_name: "JR", last_name: "HE"}}
    end
    get("/home")
    last_response.headers["Content-Type"].should == "application/json"
  end

  it "should infer serializer when there is no serializer set" do
    subject.get("/home") do
        User.new({first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk'})
    end

    get "/home"
    last_response.body.should == '{:user=>{:first_name=>"JR", :last_name=>"HE"}}'
  end

  context "serializer inference is disabled" do
    before do
      Grape::Formatter::ActiveModelSerializers.infer_serializers = false
    end

    it "should NOT infer serializer when there is no serializer set" do
      subject.get("/home") do
          User.new({first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk'})
      end

      get "/home"
      last_response.body.should == "{\"user\":{\"created_at\":null,\"first_name\":\"JR\",\"id\":null,\"last_name\":\"HE\",\"updated_at\":null,\"username\":null}}"
    end
  end

  [UserSerializer, 'user', :user].each do |serializer|
    it "should render using serializer (#{serializer})" do
      subject.get("/home", serializer: serializer) do
        User.new({first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk'})
      end

      get "/home"
      last_response.body.should == '{:user=>{:first_name=>"JR", :last_name=>"HE"}}'
    end
  end
end

