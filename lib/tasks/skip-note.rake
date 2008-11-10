namespace :skip_note do
  desc "execute some setup tasks / gems:install db:create db:migrate makemo"
  task :setup => %w[gems:install db:create db:migrate makemo]

  desc "create release .zip archive."
  task :release do
    raise "This directory is not Git repository." unless File.directory?(".git")
    require 'zip/zip'
    require 'fileutils'

    commit = ENV["COMMIT"] || "HEAD"
    if tag = ENV["TAG"]
      system(*["git", "tag", tag, commit])
      out = "skip_note-#{tag}"
      commit = tag
    else
      out = Time.now.strftime("skip_note-%Y%m%d%H%M%S")
    end
    FileUtils.mkdir_p "pkg/#{out}"
    system("git archive --format tar #{commit} | tar xvf - -C pkg/#{out}")
    Dir.chdir("pkg/#{out}") do
      %w[log tmp].each{|d| Dir.mkdir d }
      FileUtils.cp "config/database.yml.sample", "config/database.yml"
      system("rake rails:freeze:gems VERSION=2.1.2")
      system("rake gems:unpack:dependencies")
    end
    Dir.chdir("pkg") do
      system("zip #{out}.zip #{out}")
      FileUtils.rm_rf out
    end
  end
end

