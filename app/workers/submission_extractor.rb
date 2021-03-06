class SubmissionExtractor
  include Sidekiq::Worker

  def perform(submission_id)
    submission = Submission.find(submission_id)

    submission.archive.cache_stored_file!

    Dir.mktmpdir do |tmpdir|
      archive_path = File.join(tmpdir, "archive.tar.gz")
      system("cp #{submission.archive.path} #{archive_path}")
      system("tar zxf #{archive_path} -C #{tmpdir}")
      system("rm #{archive_path}")

      SourceFile.transaction do
        valid_source_files(tmpdir).each do |filename|
          SourceFile.create!(body: File.read(File.join(tmpdir, filename)),
                             submission: submission,
                             filename: filename)
        end
      end
    end
  end

  private

  def valid_source_files(dir)
    find_files(nil, dir)
  end

  def find_files(prefix, dir)
    filenames(dir).flat_map do |filename|
      path = File.join(dir, filename)

      if File.directory?(path)
        find_files(filename, path)
      else
        if prefix
          File.join(prefix, filename)
        else
          filename
        end
      end
    end
  end

  def filenames(dir)
    Dir.entries(dir).reject do |filename|
      filename == "." || filename == ".."
    end
  end
end
