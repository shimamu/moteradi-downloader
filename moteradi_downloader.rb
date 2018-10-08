#!ruby

require "net/http"
require "open-uri"

$cf = {}

$cf[:download_dir] = "./mp3"

# https://moteradi.com/tori880a.mp3
#                          ^^^
$cf[:episode_start] = 880

# https://moteradi.com/tori880a.mp3
#                             ^
$cf[:parts] = ['', 'a', 'b', 'c']

# https://moteradi.com/tori880a.mp3
#         ^^^^^^^^^^^^
$cf[:moteradi_host] = "moteradi.com"

def url_exist?(url_string)
	url = URI.parse(url_string)
	req = Net::HTTP.new(url.host, url.port)
	req.use_ssl = (url.scheme == 'https')
	path = url.path if !url.path.empty?
	res = req.request_head(path || '/')
	res.code == "200" # true if returns 200 ok
rescue Errno::ENOENT
	false # false if can't find the server
end

def create_dir(dir_string)
	if not Dir.exist?(dir_string)
		Dir.mkdir(dir_string)
	end
end

def prepare_download_dir
	create_dir($cf[:download_dir])
end

def download_file(url_string)
	prepare_download_dir

	file_path = $cf[:download_dir] + "/" + File.basename(url_string)

	print "[download] " + url_string + " => " + file_path

	open(file_path, 'wb') do |output|
		open(url_string) do |data|
			output.write(data.read)
		end
	end

	puts " (complete)"
end

def downloaded?(url_string)
	file_path = $cf[:download_dir] + "/" + File.basename(url_string)
	File.exist?(file_path)
end

def download_if_exist(url)
	print "[check] " + url + " => "
	if url_exist?(url)
		puts "exist"
		if not downloaded?(url) then
			download_file(url)
		else
			puts "[download] exist local"
		end
		return true
	else
		puts "not exist"
		return false
	end
end

def download_moteradi
	episode = $cf[:episode_start]

	parts = $cf[:parts]

	# Find file like this.
	#      https://moteradi.com/tori880.mp3
	#   -> https://moteradi.com/tori880a.mp3
	#   -> https://moteradi.com/tori880b.mp3
	#   -> https://moteradi.com/tori880c.mp3
	#   -> https://moteradi.com/tori881.mp3
	#   -> https://moteradi.com/tori881a.mp3
	#   -> ...
	#
	# If there is no part 'a' file, break loop.
	catch(:break_loop) do
		loop do
			puts "---- episode: " + episode.to_s + " ----"
			parts.each {|part|
				url = 'https://' + $cf[:moteradi_host] + '/tori' + episode.to_s + part + '.mp3'
				unless download_if_exist(url)
					if (part == 'a') then
						throw :break_loop
					elsif (part != '') then
						break;
					end
				end
			}
			episode += 1
		end
	end
end

download_moteradi

