require "geminabox"
require "rack/attack"
require 'yaml'
require 'erb'

Geminabox.data = ENV['GEMINABOX_DATA_DIR'] || "var/geminabox-data"

# Use Rack::Protection to prevent XSS and CSRF vulnerability if your geminabox server is open public.
# Rack::Protection requires a session middleware, choose your favorite one such as Rack::Session::Memcache.
# This example uses Rack::Session::Pool for simplicity, but please note that:
# 1) Rack::Session::Pool is not available for multiprocess servers such as unicorn
# 2) Rack::Session::Pool causes memory leak (it does not expire stored `@pool` hash)
use Rack::Session::Pool, expire_after: 1000 # sec
use Rack::Protection
use Rack::Attack

# • 社内（特定のIPから）であれば basic 認証なしでOK （この場合でも認証情報いれてもOK; 正しいなら）
# • 社外であっても特定のIPであれば basic 認証でOK
# • それ以外のIPからは接続できない
# • IPのリストは鯖管が簡単にコンフィグできる

module IPList
  def self.access_list(filename)
    YAML.safe_load(ERB.new(IO.read("#{File.dirname(__FILE__)}/config/#{filename}.yml")).result, [], [], true)
  end

  def office_ip
    # no require BASIC auth
    access_list('access')[ENV['RACK_ENV']]
  end

  def remote_office_ip
    # require BASIC auth
    access_list('access_remote')[ENV['RACK_ENV']]
  end

  module_function :office_ip, :remote_office_ip
end

class SkipBasicAuth < Rack::Auth::Basic
  def call(env)
    request = Rack::Request.new(env)
    if IPList.office_ip.any? { |path, ip_addresses|
        ip_addrs = ip_addresses.map { |ip_address| IPAddr.new(ip_address) }
        request.path.match(/^#{path}/) && ip_addrs.none? { |ip_addr| ip_addr.include?(request.ip) }
      }
      super
    else
      @app.call(env)
    end
  end
end

if ENV['BASIC_AUTH_USER'] && ENV['BASIC_AUTH_PASSWORD']
  # 社内アクセスは BASIC認証スキップ
  use SkipBasicAuth, "GemInAbox" do |username, password|
    ENV['BASIC_AUTH_USER'] == username && ENV['BASIC_AUTH_PASSWORD'] == password
  end
end

Rack::Attack.safelist('社外リモートアクセス') do |request|
  IPList.remote_office_ip.any? do |path, ip_addresses|
    ip_addrs = ip_addresses.map { |ip_address| IPAddr.new(ip_address) }
    request.path.match(/^#{path}/) && ip_addrs.any? { |ip_addr| ip_addr.include?(request.ip) }
  end
end

run Geminabox::Server

