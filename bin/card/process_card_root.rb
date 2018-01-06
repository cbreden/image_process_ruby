require '../../lib/image_process'

Kernel.logger.level = Logger::DEBUG
Kernel.util_verbosity = false

config = YAML.load_file('config.yml')
log config

CARD_ROOT = config['card_root'] || '/Users/igla/Desktop/mock/cardroot'
ARCHIVE_BASE_PATH = config['archive_base_path'] || '/Users/igla/Desktop/mock/archive'
PREP_BASE_PATH = config['prep_base_path'] || '/Users/igla/Desktop/mock/prep'
READY_BASE_PATH = config['ready_base_path'] || '/Users/igla/Desktop/mock/ready'

MAX_BATCH_SIZE = 300
LOOP_SLEEP = 10

loop do
card_folders = Helpers::get_subfolders CARD_ROOT
card_folders.each { |folder| 
    files = Helpers::get_all_files folder
    batches = Helpers::split_into_filetype_batches files
    batches.each { |batch| 
        unless (Helpers::has_recent_file?(batch))
            batch = batch.first(MAX_BATCH_SIZE)
            card = Tasks::create_card batch, PREP_BASE_PATH, '_CARD'
            Tasks::move_files_to_dest batch, card 
            Tasks::copy_folder_to_dest card, ARCHIVE_BASE_PATH
            ready_card = Tasks::move_folder_to_dest card, READY_BASE_PATH
            Helpers::set_folder_color ready_card, '3' # yellow
        end
    }
    Tasks::safe_delete_folder folder
}
debug "Sleeping for #{LOOP_SLEEP}s"
sleep LOOP_SLEEP
end