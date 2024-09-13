require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

#Need to first count digits of phone number in the way it's formatted. Convert to number. 

def format_home_phone(home_phone)
  home_phone.split("").reject do |num|
    ['-', '(', ')', ' ', '+', '.'].include?(num)
  end.join('')
end

def clean_home_phone(home_phone)
  cleaned_phone = format_home_phone(home_phone)
  phone_length = cleaned_phone.length
  if phone_length == 10
    return cleaned_phone.to_i
  elsif phone_length == 11 && home_phone[0] == '1'
    return cleaned_phone[1..11].to_i
  else
    return 0
  end
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('key.txt')

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def get_registration_time(reg_date)
  time = Time.strptime(reg_date, "%m/%d/%Y %k:%M")
  "#{time.hour}:#{time.min}"
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
p contents.headers

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

registration_hours = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  #I was asked to clean the phone numbers. I did so, but didn't store them anywhere. The cleaned nums are output into the "phone" variable below. 

  #TODO: Make a copy of the CSV with the cleaned phone numbers. 
  phone = clean_home_phone(row[:homephone])

  reg_date = row[:regdate]
  registration_hours.push(get_registration_time(reg_date))
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end

p registration_hours

hours_count = {}

registration_hours.each do |time|
  hour = time[0..1].to_i
  if hours_count.key?(hour)
    hours_count[hour] += 1
  else
    hours_count[hour] = 1
  end
end

p hours_count







