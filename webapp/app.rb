#!/usr/bin/env ruby

require "sinatra"
require "sinatra/cookies"
require "openssl"

configure do
  enable :inline_templates
end

helpers do
  include ERB::Util
end

set :environment, :production

HMAC_KEY = "92120ace-6795-4659-a1fc-0518faecbfbf"

def hmac(data)
  OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), HMAC_KEY, data)
end

def authentic_session?
  return false unless cookies[:session_data]
  authentic = true
  # double hmac verification
  if cookies[:session_hash] && hmac(cookies[:session_hash]) != hmac(hmac(cookies[:session_data]))
    authentic = false
  end
  return authentic
end

def current_username
  if authentic_session?
    return JSON.parse(cookies[:session_data])["username"] rescue nil
  end
end

get "/" do
  @username = current_username
  if @username.nil?
    @title = "Inebriated Alibis"
    return erb :preauth_index
  end

  @title = "Insatiable Birdie"
  erb :postauth_index
end

get "/login" do
  @title = "Inebriated Alibis"
  @error_message = params[:error].to_s if params[:error]
  erb :login
end

post "/login" do
	redirect to("/login?error=Missing parameter, friend.") unless params[:username]

  username = params[:username].to_s

  redirect to("/login?error=No.") if username.empty?

  redirect to("/login?error=No access for this user") if username == "admin"

  # intermediate variable used because cookies hands urlencoded value back
  cookies[:session_data] = session_data = {"username" => username}.to_json
  cookies[:session_hash] = hmac(session_data)
  redirect to("/")
end

get "/logout" do
  cookies.delete(:session_data)
  cookies.delete(:session_hash)
  redirect to("/")
end



__END__

@@ layout
<!doctype html>
<html>
 <head>
    <style>
    html, body {
        height: 100%;
        background-color: black;
        height: 100%;
        margin: 0px;
        padding: 0px;
        color: white;
        font-family: courier, monospace;
        text-align: center;
    }
    h1 {
        margin-top: 5%;
    }
    a {
        color: green;
    }
    input {
        padding: 10px;
    }
  </style>
  <title><%= h @title %></title>
 </head>
 <body>
  <h1><font color="OrangeRed"><%= h @title %></font></h1>
  <p><%= yield %></p>
 </body>
</html>

@@ preauth_index
<a href="/login">Are you a peasant or a god?</a>
<br /><br />
<img src="ib.jpg" />

@@ login
<% if @error_message %>
<font color="red"><%= h @error_message %></font>
<% end %>
<form action="/login" method="post">
 Username: <input name="username" />
 <br /><br />
 <input type="submit" value="Login / Register" />
</form>

@@ postauth_index
Welcome <%= h @username %>! - <a href="/logout">Logout</a><br />
<hr />
<% if @username == "admin" %>
<%= h File.read("flag.txt") %>
<% else %>
Ah, just a peasant user, I see.
<% end %>
<br /><br />
<img src="orange-birdie.jpg" />
