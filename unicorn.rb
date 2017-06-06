timeout 6000
listen 8089
log_dir = "#{ENV['HOME']}"
log_file = File.join log_dir, "lazar-rest.log"
stderr_path log_file
stdout_path log_file
