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
require 'digest'

##
# This class represent cleverbot session
#
# @author d0p1
class Cleverbot

	HOST = "www.cleverbot.com"
	ENDPOINT = "/webservicemin?uc=777"

	PARAMS = {
		'stimulus' => '', 'start' => 'y', 'sessionid' => '',
		'vText8' => '', 'vText7' => '', 'vText6' => '', 'vText5' => '',
		'vText4' => '', 'vText3' => '', 'vText2' => '',
		'icognoid' => 'wsf', 'icognocheck' => '', 'fno' => '0',
		'prevref' => '', 'emotionaloutput' => '', 'asbotname' => '',
		'ttsvoice' => '', 'typing' => '', 'lineref' => '',
		'sub' => 'Say', 'islearning' => '1', 'cleanslate' => 'false'
	}

	RESPONSE_KEY = [
		'message', 'sessionid', 'logurl', 'vText8',
		'vText7', 'vText6', 'vText5', 'vText4',
		'vText3', 'vText2', 'prevref', '',
		'emotionalhistory', 'ttsLocMP3', 'ttsLocTXT', 'ttsLocTXT3',
		'ttsText', 'lineref', 'lineURL', 'linePOST',
		'lineChoices', 'lineChoicesAbbrev', 'typingData', 'divert'
	]

	##
	# Create a new session
	def initialize (api_key="DEFAULT")
		@cookies = {}
		@params = PARAMS
		@endpoint = ENDPOINT + "&botapi=#{api_key}"
		prepare
	end

	##
	# send a message to cleverbot and get an answer
	#
	# @param message [String]
	# @return [String] the answer statement
	def send(message)
		body = @params
		body["stimulus"] = message
		body["icognocheck"] = digest(URI.encode_www_form(body)[9...35])
		body_str = URI.encode_www_form(body) #params_encode(body)

		headers = {
			'Content-Type' => 'application/x-www-form-urlencoded',
			'Content-Length' => body_str.size.to_s,
			'Cache-Control' => 'no-cache',
			'Cookie' => cookies_encode(@cookies)
		}

		req = Net::HTTP.new(HOST, 80)
		resp = req.post(@endpoint, body_str, headers)
		if resp.code != "200"
			return nil
		end
		response = resp.body.split("\r")
		save_data(response)
		return response[0]
	end

	private

	def prepare
		req = Net::HTTP.new(HOST, 80)
		resp = req.get('/')
		raw_cookies = resp.response['set-cookie']
		if not raw_cookies.nil?
			raw_cookies.scan(/(\w+)=([\w|\/]+)/) do |key, value|
				@cookies[key] = value
			end
		end
	end

	def digest(data)
		Digest::MD5.hexdigest data
	end

	def save_data(response)
		RESPONSE_KEY.each_with_index do |key, index|
			@params[key] = response[index]
		end
	end

	def cookies_encode(cookies)
		cookies.to_a.map { |cookie| "#{cookie[0]}=#{cookie[1]}" }.join(";")
	end
end
