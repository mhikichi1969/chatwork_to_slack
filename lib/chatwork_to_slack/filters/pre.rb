module ChatWorkToSlack
  module Filters
    class Pre
      def self.call(text, options)
        title_regexp = /(\[info\](\[title\]([\p{Hiragana}\p{Katakana}\p{Han}。、\w\s　]+)\[\/title\]))/
        text.scan(title_regexp).each do |title|
          text.gsub!(title[0], "*#{title[2]}*\n#{title[0]}")
          text.gsub!(title[1], '')
        end
        if data = text.match(/\[download:([\d]+)\](.*)\[\/download\]/ )
          download_msg = data[0]
          download_id = data[1]
          download_name = data[2]
          print download_msg,"\n"
          #print download_id,"\n"
          #print download_name,"\n"
          text = text.gsub(/\[download:([\d]+)\](.*)\[\/download\]/, "\n#{download_name}\n https://www.chatwork.com/gateway/download_file.php?bin=1&file_id=#{download_id}&preview=0")
          #text = text.gsub(/\[download:([\d]+)\](.*)\[\/download\]/, "")
        print text,"\n\n"
        end
        text
          .gsub(/\[code\]/, "```")
          .gsub(/\[\/code\]/, "```")
          .gsub(/\[info\]/, "```\n")
          .gsub(/\[\/info\]/, "\n```")
          #.gsub(/\[download:([\d]+)\]/, "[download_x] https://www.chatwork.com/gateway/download_file.php?bin=1&file_id=#{download_id}&preview=0 ")
          #.gsub(/\[\/download\]/, "[/download_x]")
      end
    end
  end
end
