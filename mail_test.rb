#!/usr/bin/ruby

require 'rubygems'
require 'pony'

mystring = "a\nb\nc"

Pony.mail(:to => 'abc@efg.org', :from => 'me@example.com', :subject => 'Test mail script', :body => 'Hello there.', :attachments => {"mail_test.txt" => File.read("/home/me/bin/mail_test.rb"), "mystring.txt" => mystring})
