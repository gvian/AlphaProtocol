require "openssl"
require "json"
require "socket"

system("cls")

headers = {
  :AP=>"3.0",
  :APS=>false,
  :User_Agent=>"helloworld",
  :Connection=>"keep-alive",
  :Content=>{}
}

s = TCPSocket.new "localhost", 2556

for i in 0..5
  gets
  puts ">>> " + headers.merge({:Content=>{:Request=>"HelloWorld"}}).to_json
  s.puts headers.merge({:Content=>{:Request=>"HelloWorld"}}).to_json
  puts "<<< " + JSON.parse(s.gets).to_json
end

s.puts headers.merge({:User_Agent=>"gethistory", :Connection=>"close", :Content=>{:Request=>"GET"}}).to_json
puts JSON.parse(s.gets).to_s.length
