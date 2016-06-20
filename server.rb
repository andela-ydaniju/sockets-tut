#!/usr/bin/env ruby -w
require 'socket'
# server
class Server
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @connections = {}
    @rooms = {}
    @clients = {}
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop do
      Thread.start(@server.accept) do |client|
        nick_name = client.gets.chomp.to_sym
        uniqueness_validator(nick_name, client)
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts 'Connection established. Happy chatting'
        listen_user_messages(nick_name, client)
      end
    end.join
  end

  def uniqueness_validator(name, client)
    @connections[:clients].each do |other_name, other_client|
      if name == other_name || client == other_client
        client.puts 'This username already exist'
        Thread.kill self
      end
    end
  end

  def listen_user_messages(username, client)
    loop do
      msg = client.gets.chomp
      @connections[:clients].each do |other_name, other_client|
        other_client.puts "#{username}: #{msg}" unless other_name == username
      end
    end
  end
end

Server.new(4000, 'localhost')
