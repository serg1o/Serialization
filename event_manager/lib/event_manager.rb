require "csv"
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"


def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone)
  #number_of_digits = phone.scan(/[0-9]/).size
  phone = phone.delete("-")
  if phone.length < 10
    phone = "".rjust(10,"0")
  elsif phone.length == 11
    phone[0] == "1" ? phone = phone[1..10] : phone = "".rjust(10,"0")
  elsif phone.length > 11
    phone = "".rjust(10,"0")
  end
  phone
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)

 # legislator_names = legislators.collect do |legislator|
 #   "#{legislator.first_name} #{legislator.last_name}"
 # end

  #legislator_names.join(", ")
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def most_frequent(array)
  hash = Hash.new(0)
  array.each {|d| hash[d.to_s] += 1 }
  max = hash.values.max
  most_frequent_vals = hash.collect{|k,v| k if v == max}
  most_frequent_vals.delete(nil)
  most_frequent_vals
end

puts "EventManager initialized."

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

dates = []
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = clean_phone_number(row[:homephone])

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
  dates.push(DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M'))
end

puts "Most frequent hours for registration:"
reg_hours = dates.collect {|date| date.hour}
most_frequent(reg_hours).each {|hour| puts hour}

puts "Most frequent week days for registration:"
reg_week_day =  dates.collect {|date| date.wday}
most_frequent(reg_week_day).each {|day| puts Date::DAYNAMES[day.to_i]}
