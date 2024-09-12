def format_home_phone(home_phone)
  home_phone.to_s.split("").reject do |num|
    ['-', '(', ')', ' ', '+', '.'].include?(num)
  end.join('')
end

def clean_home_phone(home_phone)
  cleaned_phone = format_home_phone(home_phone)
  phone_length = cleaned_phone.length
  if phone_length == 10
    return home_phone
  elsif phone_length == 11 && home_phone.first == '1'
    return home_phone[1..11]
  else
    return ''
  end
end

home_phone = :6154385000

p clean_home_phone(home_phone)
