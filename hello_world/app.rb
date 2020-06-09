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
  temporary_business_hours = page.search('ul.hoursOfStore').search('span').map(&:text).uniq.join('n').tr("\\n", "\n")

  # 臨時営業時間が存在する場合、メッセージに追加する
  if temporary_business_hours
    formatted_text << '下記の日程は臨時の営業時間となります。\n'
    formatted_text << temporary_business_hours
  end
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
