require "bundler/setup"
Bundler.require

# require 'httparty'
# require 'json'

### additional
# gem 'mechanize'
# gem 'slack-notifier'

def handler(event:, context:)
  agent = Mechanize.new
  page = agent.get("https://store.starbucks.co.jp/detail-1225/")

  event_descriptions = page.search('li.linkBox').search('p').map(&:text).reject(&:empty?)
  formatted_text = event_descriptions.join('\n').gsub("\\n", "\n")
  title = page.title

  to_slack(title, formatted_text)
end

def to_slack(title, formatted_text)
  notifier = Slack::Notifier.new(ENV["SLACK_INCOMING_WEBHOOK_URL"])
  attachments = {
    fallback: 'This is article notifier attachment',
    title: title,
    title_link: "https://store.starbucks.co.jp/detail-1225/",
    text: formatted_text,
    color: '#036635'
  }
  notifier.post(attachments: attachments)
end
