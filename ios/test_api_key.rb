#!/usr/bin/env ruby
require 'jwt'
require 'net/http'
require 'json'

# Read environment variables or arguments
key_id = ENV['APP_STORE_CONNECT_API_KEY_KEY_ID'] || ARGV[0]
issuer_id = ENV['APP_STORE_CONNECT_API_KEY_ISSUER_ID'] || ARGV[1]
key_content = ENV['APP_STORE_CONNECT_API_KEY_KEY'] || ARGV[2]

unless key_id && issuer_id && key_content
  puts "Usage: ruby test_api_key.rb <key_id> <issuer_id> <key_content>"
  puts "Or set env vars: APP_STORE_CONNECT_API_KEY_KEY_ID, APP_STORE_CONNECT_API_KEY_ISSUER_ID, APP_STORE_CONNECT_API_KEY_KEY"
  exit 1
end

# Write key to file
key_file = "/tmp/AuthKey_#{key_id}.p8"
File.write(key_file, key_content)
File.chmod(0600, key_file)

puts "Testing App Store Connect API key..."
puts "Key ID: #{key_id}"
puts "Issuer ID: #{issuer_id}"
puts "Key file: #{key_file}"
puts "Key starts with: #{File.read(key_file).lines.first.chomp}"

# Generate JWT token
private_key = OpenSSL::PKey::EC.new(File.read(key_file))
issued_at = Time.now.to_i
expiration_time = issued_at + 1200 # 20 minutes

payload = {
  iss: issuer_id,
  iat: issued_at,
  exp: expiration_time,
  aud: 'appstoreconnect-v1'
}

headers = {
  kid: key_id,
  typ: 'JWT'
}

token = JWT.encode(payload, private_key, 'ES256', headers)

puts "\n✅ JWT token generated (first 50 chars): #{token[0..50]}..."

# Test API endpoint
uri = URI('https://api.appstoreconnect.apple.com/v1/apps')
req = Net::HTTP::Get.new(uri)
req['Authorization'] = "Bearer #{token}"

begin
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  puts "\nAPI Response Status: #{response.code}"
  puts "API Response Body: #{response.body[0..200]}..."
  
  if response.code == '200'
    puts "✅ API key works! Can list apps."
  else
    puts "❌ API key failed. Check permissions/expiration."
    puts "Full error: #{response.body}"
  end
rescue => e
  puts "❌ Error: #{e.message}"
end

File.delete(key_file) if File.exist?(key_file)