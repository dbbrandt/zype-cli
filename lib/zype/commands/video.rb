require 'thor'
require './zype/progress_bar.rb'
require './zype/uploader.rb'

module Zype
  class Commands < Thor
    desc 'video:list', 'List videos'

    method_option 'query', desc: 'Video search terms',
                  aliases: 'q', type: :string
    method_option 'type', desc: 'Show videos of the specified type',
                  aliases: 't', type: :string, enum: ['zype','hulu','youtube']
    method_option 'category', desc: 'Video category filters',
                  aliases: 'c', type: :hash
    method_option 'active', desc: 'Show active, inactive or all videos',
                  aliases: 'a', type: :string, default: 'true', enum: ['true','false','all']
    method_option 'page', desc: 'The page of videos to return',
                  aliases: 'p', type: :numeric, default: 0
    method_option 'per_page', desc: 'The number of videos to return',
                  aliases: 's', type: :numeric, default: 25

    define_method 'video:list' do
      init_client

      videos = @zype.videos.all(
        :q => options[:query],
        :type => options[:type],
        :category => options[:category],
        :active => options[:active],
        :page => options[:page],
        :per_page => options[:per_page]
      )

      print_videos(videos)
    end

    desc 'video:update', 'Update a video'

    method_option 'id', aliases: 'i', type: :string, required: true, desc: 'Video ID'
    method_option 'active', aliases: 'a', type: :boolean, desc: 'Video active status'
    method_option 'featured', aliases: 'f', type: :boolean, desc: 'Video featured status'
    method_option 'title', aliases: 't', type: :string, desc: 'Video title'
    method_option 'description', aliases: 'd', type: :string, desc: 'Video description'
    method_option 'keywords', aliases: 'k', type: :array, desc: 'Video keywords'

    define_method 'video:update' do
      init_client

      if video = @zype.videos.find(options[:id])
        video.title = options[:title] unless options[:title].nil?
        video.keywords = options[:keywords] unless options[:keywords].nil?
        video.active = options[:active] unless options[:active].nil?
        video.featured = options[:featured] unless options[:featured].nil?
        video.description = options[:description] unless options[:description].nil?

        video.save
        print_videos([video])
      end
      puts ''
    end

    desc 'video:upload', 'Upload a video'

    method_option 'title', aliases: 't', type: :string, required: false, desc: 'Video title'
    method_option 'keywords', aliases: 'k', type: :array, desc: 'Video keywords'

    method_option 'filename', aliases: 'f', type: :string, required: false, desc: 'File path to upload'
    method_option 'directory', aliases: 'd', type: :string, required: false, desc: 'Directory to upload'

    define_method 'video:upload' do
      init_client

      filenames = []

      if filename = options[:filename]
        filenames << filename
      end

      if directory = options[:directory]
        directory = directory.chomp('/')
        filenames += Dir.glob(directory + '/*').reject{|f| f =~ /(^\.\.)|(^\.)/}
      end

      filenames.each do |filename|
        upload_and_transcode_video(filename, options)
      end
    end

    no_commands do

      def print_videos(videos)
        puts Hirb::Helpers::Table.render(videos, :fields=>[:_id, :title, :description, :filename, :duration, :status, :active])
      end

      def upload_and_transcode_video(filename,options)
        upload = upload_video(filename)
        if upload.status == 'complete'
          transcode_video(upload, title: options[:title] || upload.filename, keywords: options[:keywords])
        end
      end

      def transcode_video(upload,options={})
        @zype.videos.create(options.merge(upload_id: upload._id))
      end

      def upload_video(filename)
        file = File.open(filename)
        basename = File.basename(filename)

        upload = @zype.uploads.create(filename: basename, filesize: file.size)

        begin
          uploader = Zype::Uploader.new(@zype)
          uploader.process(upload,file)

          upload.progress = 100
          upload.status = 'complete'
        rescue Interrupt => e
          puts 'Upload Cancelled'
          upload.status = 'cancelled'
        rescue Exception => e
          upload.status = 'error'
          upload.message = "Error: ##{e.message}"
          raise
        ensure
          upload.save
        end
        puts ''
        upload
      end
    end
  end
end
