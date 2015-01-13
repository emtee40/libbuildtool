require 'net/http'

class Fetcher < LBT::StepsFabricator
	class HTTP < LBT::Step
		def initialize url
			@url     = url
		end
		def run
			Dir.chdir $global_state.source_dir

			# Early-bailing to not download multiple times.
			puts "Checking for existence of file #{@library.archive}"
			if ::File.exist? @library.archive
				puts "Found, will not download."
				return true
			end
			puts "Not found, will download."

			if Functions.program_exists 'curl'
				return Exec.run "curl", "-L", @url, "-o", "#{$global_state.source_dir}/#{@library.archive}"
			elsif Functions.program_exists 'wget'
				return Exec.run "wget", "--no-check-certificate", "-O", "#{$global_state.source_dir}/#{@library.archive} #{@url}", @url
			else
				puts 'No tool available to fetch from http.'
				return false
			end
		end
	end
	class Copy < LBT::Step
		def initialize archive
			@library.archive = archive
		end
		def run
			Dir.chdir $global_state.source_dir
			path = @path || @url

			dest = "#{$global_state.source_dir}/#{@library.archive}"
			FileUtils.cp_r path, dest
			return true
		end
	end
end
