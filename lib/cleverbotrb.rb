# Copyright (c) 2016 d0p1 <d0p1@yahoo.com>
# Author: d0p1 <d0p1@yahoo.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLU
# DING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'uri'
require 'net/http'
require 'json'

##
# This class represent cleverbot session
#
# @author d0p1
class Cleverbot

	HOST = "www.cleverbot.com"
	ENDPOINT = "/getreply?"

	##
	# Create a new session
	def initialize (api_key)
		@params = {
			"key" => api_key,
			"wrapper" => "cleverbotrb"
		}
		@endpoint = ENDPOINT
	end

	##
	# send a message to cleverbot and get an answer
	#
	# @param message [String]
	# @return [String] the answer statement
	def send(message)
		url_arg = @params
		url_arg["input"] = message
		url_arg_str = URI.encode_www_form(url_arg)

		headers = {
			'User-Agent' => 'cleverbotrb https://github.com/d0p1s4m4/cleverbotrb',
		}

		req = Net::HTTP.new(HOST, 80)
		resp = req.get(@endpoint + url_arg_str, headers)
		if resp.code != "200"
			return nil
		end
		response = JSON.parse(resp.body)
		@params['cs'] = response['cs']
		return response['output']
	end

	def reset
		params.delete('cs')
	end
end
