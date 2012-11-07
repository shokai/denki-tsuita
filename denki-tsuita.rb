#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler'
Bundler.require

threshold = 350

client = Tw::Client.new
client.auth 'shokai_log'

tweets = client.user_timeline('shokai_log').select{|m|
  Time.now - m.time < 60*60
}.sort{|a,b|
  b.time <=> a.time
}.map{|m|
  JSON.parse m.text rescue nil
}.select{|m|
  m.kind_of? Hash and [Fixnum, Float].include? m["明るさ"].class
}

p tweets

if tweets.size < 2
  msg = '明るさが取得できません'
  STDERR.puts msg
  client.tweet "@shokai #{msg}"
  exit 1
end

if tweets[0]['明るさ'] < threshold and tweets[1]['明るさ'] > threshold
  puts msg = "電気消えた"
  client.tweet "@shokai #{msg}"
elsif tweets[0]['明るさ'] > threshold and tweets[1]['明るさ'] < threshold
  puts msg = "電気ついた"
  client.tweet "@shokai #{msg}"
else
  puts '明るさ変化なし'
end
