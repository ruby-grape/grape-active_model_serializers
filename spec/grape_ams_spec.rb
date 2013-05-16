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
    subject.get("/home/users", :serializer => "user") do
      {user: {first_name: "JR", last_name: "HE"}}
    end
    get("/home/users")
    last_response.headers["Content-Type"].should == "application/json"
  end

  it "should infer serializer when there is no serializer set" do
    subject.get("/home") do
      User.new({first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk'})
    end

    get "/home"
    last_response.body.should == "{\"user\":{\"first_name\":\"JR\",\"last_name\":\"HE\"}}"
  end

  it "should serializer arrays of objects" do
    subject.get("/home") do
      user = User.new({first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk'})
      [user, user]
    end

    get "/home"
    last_response.body.should == "{\"users\":[{\"first_name\":\"JR\",\"last_name\":\"HE\"},{\"first_name\":\"JR\",\"last_name\":\"HE\"}]}"
  end

  context "for models with compound names" do
    it "should generate the proper 'root' node for individual objects" do
      subject.get("/home") do
        BlogPost.new({title: 'Grape AM::S Rocks!', body: 'Really, it does.'})
      end

      get "/home"
      last_response.body.should == "{\"blog_post\":{\"title\":\"Grape AM::S Rocks!\",\"body\":\"Really, it does.\"}}"
    end

    it "should generate the proper 'root' node for serialized arrays of objects" do
      subject.get("/home") do
        blog_post = BlogPost.new({title: 'Grape AM::S Rocks!', body: 'Really, it does.'})
        [blog_post, blog_post]
      end

      get "/home"
      last_response.body.should == "{\"blog_posts\":[{\"title\":\"Grape AM::S Rocks!\",\"body\":\"Really, it does.\"},{\"title\":\"Grape AM::S Rocks!\",\"body\":\"Really, it does.\"}]}"
    end
  end

  it "uses namespace options when provided" do
    subject.namespace :admin, :serializer => UserSerializer do
      get('/jeff') do
        User.new(first_name: 'Jeff')
      end
    end

    get "/admin/jeff"
    last_response.body.should == "{\"user\":{\"first_name\":\"Jeff\",\"last_name\":null}}"
  end

  # [User2Serializer, 'user2', :user2].each do |serializer|
  #   it "should render using serializer (#{serializer})" do
  #     subject.get("/home", serializer: serializer) do
  #       User.new({first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk'})
  #     end

  #     get "/home"
  #     last_response.body.should == "{\"user\":{\"first_name\":\"JR\",\"last_name\":\"HE\"}}"
  #   end
  # end


end

