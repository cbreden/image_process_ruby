require '../../lib/image_process'

$stdout.sync = true 
$stdin.sync = true

Kernel.logger.level = Logger::DEBUG
Kernel.util_verbosity = false

config = YAML.load_file('config.yml')
log config

FTP_ROOT = config['ftp_root'] || '/Users/igla/Desktop/mock/ftproot'
ARCHIVE_BASE_PATH = config['archive_base_path'] || '/Users/igla/Desktop/mock/archive'
PREP_BASE_PATH = config['prep_base_path'] || '/Users/igla/Desktop/mock/prep'
READY_BASE_PATH = config['ready_base_path'] || '/Users/igla/Desktop/mock/ready'

DESIRED_BATCH_SIZE = 50
# MAX_AGE = 10  # debugging age seconds
MAX_AGE = 150  # seconds
MAX_BATCH_SIZE = 150
LOOP_SLEEP = 10

loop do
ftp_home_folders = Helpers::get_subfolders FTP_ROOT
ftp_home_folders.each { |folder| 
    files = Helpers::get_all_files folder
    batches = Helpers::split_into_filetype_batches files
    batches.each { |batch| 
        if (Helpers::has_old_file?(batch,MAX_AGE) or Helpers::has_enough_files?(batch,DESIRED_BATCH_SIZE))
            batch = Helpers::trim_files_recently_touched batch
            batch = batch.first(MAX_BATCH_SIZE)
            unless batch.empty? 
                card = Tasks::create_card batch, PREP_BASE_PATH, '_FTP' + File.basename(folder)
                Tasks::move_files_to_dest batch, card 
                Tasks::copy_folder_to_dest card, ARCHIVE_BASE_PATH
                ready_card = Tasks::move_folder_to_dest card, READY_BASE_PATH
                Helpers::set_folder_color ready_card, '3' # yellow
            end
        end
    }
}
log "Sleeping for #{LOOP_SLEEP}s"
sleep LOOP_SLEEP
end