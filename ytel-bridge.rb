require 'sinatra'
require 'google_drive'

require_relative 'settings'

#https://docs.google.com/spreadsheet/formResponse?hl=en_US&formkey=fLEDZdERzejNIelEtSkNTMl90ZWdMN1pma0E&first=--A--first_name--B--
# &last=--A--last_name--B--&phone=--A--phone_number--B--&email=--A--email—B—&organization=--A--address1--B--
# &address=--A--address2—B—&city=--A--city--B--&state=--A--state--B--&zip=--A--postal_code--B--
# &alt_phone=--A--alt_phone--B--&agent=--A--fullname—B—&time=—A—SQLdate—B—&notes=--A--comments--B--

class YTel < Sinatra::Base
  get '/' do
    session = GoogleDrive.login(Settings.google.username, Settings.google.password)
    ws = session.spreadsheet_by_key(Settings.google.doc_id).worksheets[0]

    new_row_num = ws.rows.length + 1

    ws[new_row_num, 1] = Time.now.to_s
    ws[new_row_num, 2] = params['agent']
    ws[new_row_num, 3] = params['organization']

    ws[new_row_num, 4] = params['first']

    ws[new_row_num, 5] = params['last']

    ws[new_row_num, 6] = "#{params['address']} #{params['address2']}"
    ws[new_row_num, 7] = params['city']
    ws[new_row_num, 8] = params['state']
    ws[new_row_num, 9] = params['zip']
    ws[new_row_num, 10] = params['phone']
    ws[new_row_num, 11] = params['email']
    ws[new_row_num, 12] = params['notes']

    ws.save

    'OK'
  end
end

