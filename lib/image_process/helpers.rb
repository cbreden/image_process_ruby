module Helpers
    def self.get_subfolders root_folder
        debug "Getting all folders inside #{root_folder}"
        subfolders = Dir.glob("#{root_folder}/*").select {|f| File.directory? f}
        debug "subfolders found: #{subfolders}"
        return subfolders
    end

    def self.get_all_files folder
        debug "Getting all files inside folder #{folder}"
        files = Dir.glob("#{folder}/*").select {|f| File.file? f}.select {|f| File.basename(f) !~ /tmp/}.sort_by{ |f| [File.mtime(f), f] }
        debug "files found: #{files}"
        return files
    end

    def self.split_into_filetype_batches files
        # possibly do some conversion of accepted filetypes here
        #  and batch unwanted stuff into 'MISC'
        debug "Splitting files into each extension type"
        h = Hash.new { |h, k| h[k] = Array.new }
        files.each { |f| 
            ext = File.extname(f).upcase[1..-1]
            h[ext] << f
        }
        debug "Extensions found: #{h.keys}"
        debug "returning #{h.values.inspect}"
        return h.values
    end

    def self.has_old_file? files, max_age
        debug "getting oldest file..."
        oldest_file = get_oldest_file files
        # check = (file.last_modified > now - max_age)
        check = (File.mtime(oldest_file) < Time.now - max_age)
        check ? (log "Has file old enough") : (debug "Doesn't have file old enough")
        return check
    end

    def self.has_recent_file? files
        debug "checking for recently touched files..."
        recent_files = files.select{|f| File.ctime(f) > Time.now - 15}
        check = recent_files.any?
        check ? (debug "Has recently touched file") : (debug "No recently touched files")
        return check
    end

    def self.has_enough_files? files, desired_count
        check = (files.length >= desired_count)
        check ? (log "Has enough files") : (debug "Doesn't have enough files")
        return check
    end

    def self.get_oldest_file files
        debug "file ages: #{files.map{|f| f + " " + File.mtime(f).to_s}.inspect}"
        file = files.sort_by{ |f| File.mtime f }.first
        debug "oldest file: #{file} #{File.mtime(file).to_s}"
        return file
    end

    def self.trim_files_recently_touched files
        debug "checking for recently touched files..."
        recent_files = files.select{|f| File.ctime(f) > Time.now - 15}
        log "skipping recent files: #{recent_files.inspect}" unless recent_files.empty?
        return files - recent_files
    end

    def self.set_folder_color folder, color
        command = %Q(osascript -e "tell application \\"Finder\\" to set label index of alias POSIX file \\"#{folder}\\" to #{color}"> /dev/null)
        `#{command}`
    end
end