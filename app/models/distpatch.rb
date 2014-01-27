# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: distpatches
#
#  id           :integer          not null, primary key
#  category_id  :integer
#  published    :datetime
#  point_lat    :float
#  point_long   :float
#  created_at   :datetime
#  updated_at   :datetime
#  updated      :datetime
#  address      :string(255)
#  agency_id    :integer
#  responder_id :string(14)       not null
#  last_updated :datetime         not null
#  location     :string
#

require 'simple-rss'
require 'open-uri'

 # PP    - Portland Police
 # PG    - Gresham Police
 # PT    - Troutdale Police
 # PF    - Fairview Police
 # PM    - Multnomah County Sherriff
 # PA    - Port of Portland Police (Airport)
 # PO    - Other Police (OSP, Parole & Probation…)
 # RP    - Portland Fire & Rescue
 # RG    - Gresham Fire
 # RC    - Corbett Fire
 # RS    - Sauvie Island Fire
 # RA    - Port of Portland Fire (Airport)
 # RO    - Other Fire
 # MD    - Multnomah County EMS

class Hash
  def diff(other)
    (self.keys + other.keys).uniq.inject({}) do |memo, key|
      unless self[key] == other[key]
        if self[key].kind_of?(Hash) &&  other[key].kind_of?(Hash)
          memo[key] = self[key].diff(other[key])
        else
          memo[key] = [self[key], other[key]] 
        end
      end
      memo
    end
  end
end

class Distpatch < ActiveRecord::Base

  acts_as_mappable lng_column_name: :point_long, lat_column_name: :point_lat

  belongs_to :category
  belongs_to :agency

  DD_RE  = /dd&gt;(.+)&lt;\/dd/
  DT_RE  = /dt&gt;(.+)&lt;\/dt/
  DL_RE  = /dl&gt;(.+)&lt;\/dl/

  DATE_FMT  = '%m/%d/%y %I:%M:%S %p %Z'
  XML_SET   = [:published, :updated]

  public

  def to_kml()
    name = self.category.label + ' at ' + self.address
    desc = name + ' ['  + agency.name + ' #' + responder_id + ']' + "\n\n" + 
      self.updated.localtime.to_s + "\n"
    coord = self.point_long.to_s + ',' + self.point_lat.to_s
    builder =  Nokogiri::XML::Builder.new do |xml|
      xml.Placemark {
        xml.name              name
        xml.description       desc
        xml.styleUrl          '#police'
        xml.point {
          xml.coordinates     coord
        }
      }
    end
    puts builder.to_xml
    nil
  end

  def self.monitor(interval = 75)
    while true
      Rails.logger.silence(ActiveSupport::Logger::WARN) do
        begin
          num = Distpatch.refresh
          puts "#{num} Dispatch events logged at #{Time.now}, sleeping #{interval} secs" 
        rescue => e
          puts e.inspect
        ensure
          sleep(interval)
        end
      end
    end
  end

  def self.refresh()
    cnt = 0;
    @@doc ||= Nokogiri::HTML::Document.new()

    SimpleRSS.item_tags << :"georss:point"
    rss = SimpleRSS.parse(open('http://www.portlandonline.com/scripts/911incidents.cfm'))
    rss.entries.each do |e|
      dispatch = self.new
      dispatch.point_lat, dispatch.point_long = e.delete(:georss_point).split.map(&:to_f)
      dispatch.published = e[:published]
      dispatch.updated = e[:updated]
      #
      # brute force parsing of embedded html-formatted data
      #
      frag = @@doc.fragment(CGI::unescapeHTML(e[:content]))
      cattrs = self.parse_content(frag.children.children.children.map(&:text))
      dt = DateTime.strptime(cattrs[:last_updated], DATE_FMT)
      dispatch.last_updated = dt
      code = cattrs[:responder_id][0..1]
      dispatch.address = cattrs[:address]
      dispatch.responder_id = cattrs[:responder_id]
      if ( (rec = self.find_by(responder_id: dispatch.responder_id)) )
        if ( rec.updated != dispatch.last_updated )
          dispatch.category = Category.find_or_create_by!(label: cattrs[:call_type])
          dispatch.agency = Agency.find_or_create_by!(code: code, name: cattrs[:agency])
          logger.warn("UniqueId reused! record delta: #{rec.attributes.diff(dispatch.attributes)}")
        end
      else
        dispatch.category = Category.find_or_create_by!(label: cattrs[:call_type])
        dispatch.agency = Agency.find_or_create_by!(code: code, name: cattrs[:agency])
        dispatch.save!
        cnt += 1
      end
    end
    cnt
  end

  def self.parse_content(array)
    array.insert(3, "Unknown") if array.length.odd?
    src_hash, ret_hash = Hash[*array], {}
    src_hash.keys.each { |key| ret_hash[key.gsub(/\s/, '_')[0..-2].downcase.to_sym] = src_hash[key] }
    ret_hash[:responder_id] = ret_hash[:id]
    ret_hash.delete(:id)
    return ( ret_hash )
  end
end
