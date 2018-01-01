module Tasks
    def self.create_card file_batch, dest_folder, src_label=nil
        oldest_file = Helpers::get_oldest_file file_batch
        debug "making card from oldest file: #{oldest_file} #{File.mtime(oldest_file).to_s}"

        timestamp = File.mtime(oldest_file).strftime("%d%H%M")
        ext = File.extname(oldest_file).upcase[1..-1]
        name = File.basename(oldest_file)
        type = nil
        id = nil
        case ext
            when /NEF/
                type = 'RAW'
                id = "_" + name.split('_').first[0..3]
            when /CR2/
                type = 'RAW'
                id = "_" + name.split('_').first[0..3]
            when /JPG/
                type = 'JPG'
                id = "_" + name.split('_').first[0..3]
            else
                type = 'MISC'
        end
        name_suffix = Digest::SHA256.hexdigest(name)[0..3]
        rand_suffix = rand(36**4).to_s(36) # length of 4

        new_folder_name = "#{timestamp}#{id}_#{type}#{src_label}_#{name_suffix}-#{rand_suffix}"

        card_path = dest_folder + '/' + new_folder_name
        Dir.mkdir card_path
        log "created card: #{card_path}"
        return card_path
    end

    def self.move_files_to_dest files, dest_folder
        debug "moving files #{files} to #{dest_folder}"
        FileUtils.mv files, dest_folder, :verbose => util_verbosity
        log "moved files to #{dest_folder}"
        return dest_folder
    end

    def self.copy_folder_to_dest folder, dest_folder_base
        debug "starting copy of #{folder} to #{dest_folder_base}"
        size = Dir.glob("#{folder}/*").map{|f| File.size(f)}.reduce(0, :+) / (1024 * 1024) # folder size in MB
        # there is also a `FileUtils.copy_entry` that might be worth using if cp_r is weird
        time = Benchmark.realtime { 
            FileUtils.cp_r folder, dest_folder_base, :verbose => util_verbosity
        }
        log "copied #{folder} to #{dest_folder_base} in #{sprintf('%.2f',time)}s (#{sprintf('%.2f', size/time)} MBps copied)"
        return dest_folder_base + '/' + File.basename(folder)
    end

    def self.move_folder_to_dest folder, dest_folder_base
        debug "starting move of #{folder} to #{dest_folder_base}"
        size = Dir.glob("#{folder}/*").map{|f| File.size(f)}.reduce(0, :+) / (1024 * 1024) # folder size in MB
        time = Benchmark.realtime { 
            FileUtils.mv folder, dest_folder_base, :verbose => util_verbosity
        }
        debug "moved #{folder} to #{dest_folder_base} in #{sprintf('%.2f', time)}s (#{sprintf('%.2f', size/time)} MBps moved)"
        return dest_folder_base + '/' + File.basename(folder)
    end

    def self.delete_files files
        debug "deleting files: #{files}"
        FileUtils.rm files, :verbose => util_verbosity
        debug "deleted files"
    end

    def self.safe_delete_folder folder
        if Dir[folder + "/*"].empty?
            FileUtils.rmdir folder, :verbose => util_verbosity
            debug "deleted folder #{folder}"
        else
            debug "Folder not empty #{folder}"
        end
    end
end