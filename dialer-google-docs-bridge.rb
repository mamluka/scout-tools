require 'sinatra'
require 'google_drive'

require_relative 'settings'

#https://docs.google.com/spreadsheet/formResponse?hl=en_US&formkey=fLEDZdERzejNIelEtSkNTMl90ZWdMN1pma0E&first=--A--first_name--B--
# &last=--A--last_name--B--&phone=--A--phone_number--B--&email=--A--email—B—&organization=--A--address1--B--
# &address=--A--address2—B—&city=--A--city--B--&state=--A--state—B—&zip=--A--postal_code--B--
# &alt_phone=--A--alt_phone--B--&agent=--A--fullname—B—&time=—A—SQLdate—B—&notes=--A--comments--B--

get '/dialer-bridge' do
  session = GoogleDrive.login(Settings.google.login, Settings.google.password)
end