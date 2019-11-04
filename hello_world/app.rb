# require 'httparty'
# require 'json'
# require 'mechanize'
# require 'slack-notifier'

require "bundler/setup"
Bundler.require

def lambda_handler(event:, context:)
  agent = Mechanize.new
  page = agent.get("https://store.starbucks.co.jp/detail-1225/")

  event_descriptions = page.search('li.linkBox').search('p').map(&:text).reject(&:empty?)
  formatted_text = event_descriptions.join('\n').gsub("\\n", "\n")
  title = page.titlee

  to_slack(title, formatted_text)

  # {
  #   statusCode: 200,
  #   body: {
  #     message: event_descriptions,
  #     # location: response.body
  #   }.to_json
  # }
end

def to_slack(title, formatted_text)
  notifier = Slack::Notifier.new(ENV["SLACK_INCOMING_WEBHOOK_URL"])
  attachments = {
    fallback: 'This is article notifier attachment',
    title: title,
    text: formatted_text,
    color: '#036635'
  }
  notifier.post(attachments: attachments)
end

# def debug
#   agent = Mechanize.new
#   page = agent.get("https://store.starbucks.co.jp/detail-1225/")

#   event_descriptions = []
#   page.search('li.linkBox').search('p').each do |element|
#     next if element.text == ""
#     event_descriptions << element.text
#   end

#   p formatted_text = event_descriptions.join("\n")
# end

# debug