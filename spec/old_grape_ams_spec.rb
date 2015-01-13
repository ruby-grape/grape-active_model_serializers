require 'spec_helper'
require 'support/models/user'
require 'support/models/blog_post'
require 'support/serializers/user_serializer'
require 'support/serializers/blog_post_serializer'
require 'grape-active_model_serializers'

describe Grape::ActiveModelSerializers do
  let(:app) { Class.new(Grape::API) }
  subject { last_response.body }

  before do
    app.format :json
    app.formatter :json, Grape::Formatter::ActiveModelSerializers
  end

  it 'should respond with proper content-type' do
    app.get('/home/users', serializer: UserSerializer) do
      User.new
    end
    get('/home/users')
    expect(last_response.headers['Content-Type']).to eql 'application/json'
  end

  context 'serializer is set to nil' do
    before do
      app.get('/home', serializer: nil) do
        { user: { first_name: 'JR', last_name: 'HE' } }
      end
    end
    it 'uses the built in grape serializer' do
      get('/home')
      expect(subject).to eql "{\"user\":{\"first_name\":\"JR\",\"last_name\":\"HE\"}}"
    end
  end

  context "serializer isn't set" do
    before do
      app.get('/home') do
        User.new(first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk')
      end
    end

    it 'infers the serializer' do
      get '/home'
      expect(subject).to eql "{\"user\":{\"first_name\":\"JR\",\"last_name\":\"HE\"}}"
    end
  end

  it 'serializes arrays of objects' do
    app.get('/users') do
      user = User.new(first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk')
      [user, user]
    end

    get '/users'
    expect(subject).to eql "{\"users\":[{\"first_name\":\"JR\",\"last_name\":\"HE\"},{\"first_name\":\"JR\",\"last_name\":\"HE\"}]}"
  end

  context 'models with compound names' do
    it "generates the proper 'root' node for individual objects" do
      app.get('/home') do
        BlogPost.new(title: 'Grape AM::S Rocks!', body: 'Really, it does.')
      end

      get '/home'
      expect(subject).to eql "{\"blog_post\":{\"title\":\"Grape AM::S Rocks!\",\"body\":\"Really, it does.\"}}"
    end

    it "generates the proper 'root' node for serialized arrays" do
      app.get('/blog_posts') do
        blog_post = BlogPost.new(title: 'Grape AM::S Rocks!', body: 'Really, it does.')
        [blog_post, blog_post]
      end

      get '/blog_posts'
      expect(subject).to eql "{\"blog_posts\":[{\"title\":\"Grape AM::S Rocks!\",\"body\":\"Really, it does.\"},{\"title\":\"Grape AM::S Rocks!\",\"body\":\"Really, it does.\"}]}"
    end
  end

  it 'uses namespace options when provided' do
    app.namespace :admin, serializer: UserSerializer do
      get('/jeff') do
        User.new(first_name: 'Jeff')
      end
    end

    get '/admin/jeff'
    expect(subject).to eql "{\"user\":{\"first_name\":\"Jeff\",\"last_name\":null}}"
  end

  context 'route is in a namespace' do
    it 'uses the name of the closest namespace for the root' do
      app.namespace :admin do
        get('/jeff') do
          user = User.new(first_name: 'Jeff')
          [user, user]
        end
      end

      get '/admin/jeff'
      expect(subject).to eql "{\"admin\":[{\"first_name\":\"Jeff\",\"last_name\":null},{\"first_name\":\"Jeff\",\"last_name\":null}]}"
    end
  end

  context 'route is not in a namespace' do
    it 'uses the of the route for the root' do
      app.get('/people') do
        user = User.new(first_name: 'Jeff')
        [user, user]
      end

      get '/people'
      expect(subject).to eql "{\"people\":[{\"first_name\":\"Jeff\",\"last_name\":null},{\"first_name\":\"Jeff\",\"last_name\":null}]}"
    end
  end
end
