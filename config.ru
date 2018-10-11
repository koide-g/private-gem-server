require "geminabox"

Geminabox.data = "var/geminabox-data" # ... or wherever

# Use Rack::Protection to prevent XSS and CSRF vulnerability if your geminabox server is open public.
# Rack::Protection requires a session middleware, choose your favorite one such as Rack::Session::Memcache.
# This example uses Rack::Session::Pool for simplicity, but please note that:
# 1) Rack::Session::Pool is not available for multiprocess servers such as unicorn
# 2) Rack::Session::Pool causes memory leak (it does not expire stored `@pool` hash)
use Rack::Session::Pool, expire_after: 1000 # sec
use Rack::Protection

if ENV['BASIC_AUTH_USER'] && ENV['BASIC_AUTH_PASSWORD']
  use Rack::Auth::Basic, "GemInAbox" do |username, password|
    ENV['BASIC_AUTH_USER'] == username && ENV['BASIC_AUTH_PASSWORD'] == password
  end
end

run Geminabox::Server
