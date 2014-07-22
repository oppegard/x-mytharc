require 'nokogiri'
class EpisodeFinder
  def self.load_from_xml
    xml_string = File.read(File.expand_path('../assets/x-files_episodes.xml', __FILE__))
    xml_doc = Nokogiri::XML(xml_string)
    xml_doc.css('Season').map { |season_xml| XFilesSeason.from_xml(season_xml) }
  end
end

class XFilesSeason < Array
  def self.from_xml(xml)
    new(xml.css('episode').map { |episode_xml| XFilesEpisode.from_xml(episode_xml) })
  end

  def find_by_title(title)
    detect { |ep| ep.title.downcase == title.downcase }
  end

  def next_in_mytharc(title = nil)
    starting_index = title.nil? ? 0 : index(find_by_title(title)) + 1
    slice(starting_index..-1).detect { |ep| ep.mytharc? }
  end
end

require 'ostruct'
require 'date'
class XFilesEpisode < OpenStruct
  def self.from_xml(xml)
    ep_args = xml.children.to_a.reduce({}) { |memo, e| memo.merge(e.name.to_sym => e.inner_text) }
    ep_args[:airdate] = Date.parse(ep_args.fetch(:airdate))
    ep_args[:epnum] = ep_args.fetch(:epnum).to_i
    ep_args[:seasonnum] = ep_args.fetch(:seasonnum).to_i
    mytharc = xml['mytharc'] == 'true' ? true : false
    XFilesEpisode.new(ep_args.merge(mytharc?: mytharc))
  end

  def initialize(args={})
    known_keys = [:title, :mytharc?]
    known_keys.each { |k| raise "required arg #{k} not found in #{args}" unless args.has_key?(k) }

    super(args)
  end
end
