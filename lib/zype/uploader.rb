require 'aws-sdk'
require './zype/file_reader.rb'

module Zype
  class Uploader
    CHUNK_SIZE = 5 * 1024 * 1024
    PART_SIZE = 5 * 1024 * 1024
    MULTIPART_MINIMUM = 10 * 1024 * 1024 # 10 MB

    def initialize(client)
      @client = client

      init_aws_client
    end

    def init_aws_client
      account = @client.account

      unless account.upload_key && account.upload_secret
        raise Zype::Client::NoUploadKey, "Upload credentials not found"
      end

      @aws = AWS::S3.new(
        access_key_id: account.upload_key,
        secret_access_key: account.upload_secret
      )
    end

    def process(upload,file)
      progress_bar = Zype::ProgressBar.new(upload["filename"], file.size)

      upload.status = 'uploading'
      last_check = Time.now

      file = Zype::FileReader.new(file) do |reader|
        progress_bar.set(reader.pos)

        if last_check < Time.now - 10 # seconds
          progress = (file.pos.to_f / file.size * 100).floor

          update_progress(upload,progress)

          last_check = Time.now
        end
      end

      uri = URI.parse(upload.path)

      bucket = @aws.buckets[upload.bucket]
      object = bucket.objects[upload.path]

      object.write(file, :multipart_min_part_size => MULTIPART_MINIMUM)
    end

  private

    def update_progress(upload,progress)
      upload.progress = progress
      upload.save
    rescue Exception
      # catch exceptions on periodic checkins
    end
  end
end
