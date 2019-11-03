# require 'httparty'
# require 'json'
# require 'mechanize'

require "bundler/setup"
Bundler.require

def lambda_handler(event:, context:)

  agent = Mechanize.new
  page = agent.get("https://store.starbucks.co.jp/detail-1225/")

  event_descriptions = []
  page.search('li.linkBox').search('p').each do |element|
    p element
    next if element.text == ""
    event_descriptions << element.text
  end

  { "text": event_descriptions }

  # {
  #   statusCode: 200,
  #   body: {
  #     message: event_descriptions,
  #     # location: response.body
  #   }.to_json
  # }
end

# def debug
#   agent = Mechanize.new
#   page = agent.get("https://store.starbucks.co.jp/detail-1225/")

#   event_descriptions = []
#   page.search('li.linkBox').search('p').each do |element|
#     next if element.text == ""
#     event_descriptions << element.text
#   end

#   p event_descriptions
# end

# debug