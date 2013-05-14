require 'fileutils'
require 'digest/md5'
require 'tempfile'

module Jekyll
  class DitaaBlock < Liquid::Block
    def initialize(tag_name, options, tokens)
      super

      java_is_installed = system('java -version')

      # There is always a blank line at the beginning, so we remove to get rid
      # of that undesired top padding in the ditaa output
      ditaa = @nodelist.to_s
      ditaa.gsub!('\n', "\n")
      ditaa.gsub!(/^$\n/, "")
      ditaa.gsub!(/^\[\"\n/, "")
      ditaa.gsub!(/\"\]$/, "")
      ditaa.gsub!(/\\\\/, "\\")

      hash = Digest::MD5.hexdigest(@nodelist.to_s + options)
      ditaa_home = File.join('images', 'ditaa') #dirpath images/ditaa
      FileUtils.mkdir_p(ditaa_home)
      @png_name = File.join(ditaa_home, "ditaa-#{hash}.png") #filepath images/ditaa/ditaa-computedhash.png
      ditaa_jar = File.join(File.dirname(__FILE__), 'ditaa0_9', 'ditaa0_9.jar') ## ditaa_rb_file_path/ditaa0_9/ditaa0_9.jar

      if java_is_installed
        if not File.exists?(@png_name)
          args = ' ' + options + ' -o'
          temp_file = Tempfile.new(['ditaa-foo', '.txt'])
          temp_file.write(ditaa)
          temp_file.close
          @png_exists = system("java -jar #{ditaa_jar} #{temp_file.path} #{@png_name} #{args}")
          temp_file.unlink
        end
      end
      @png_exists = File.exists?(@png_name)
    end

    def render(context)
      if @png_exists
        %Q|<figure><a href="/#{@png_name}" title="#{@png_name}"><img src="/#{@png_name}" title="#{@png_name}" max-width="99%" /></a></figure>|
      else
        # prepend four blank spaces to txt diagram (markdown use <code /> tag)
        super.gsub(/^(.*)$/, '    \1')
      end
    end
  end
end

Liquid::Template.register_tag('ditaa', Jekyll::DitaaBlock)
