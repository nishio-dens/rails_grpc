require "singleton"
require "rails_grpc/boot"

module RailsGrpc
  class CLI
    include Singleton

    WORKER_LAUNCH_RETRY_LIMIT = 3
    RAILS_LAUNCH_WAIT_TIME = 10 # FIXME

    attr_accessor :worker_pid, :server, :mutex

    def initialize
      @mutex = Mutex.new
      set_environment
    end

    def parse
    end

    def run
      @worker_pid = Process.fork
      if @worker_pid
        print_banner
        puts "Start GRPC master (pid: #{$$})"
        set_master_trap
        Process.waitall
      else
        boot_grpc_server
      end
    end

    private

    def set_environment
      env ||= ENV["RAILS_ENV"]
      env ||= ENV["RACK_ENV"]
      env ||= "development"

      ENV["RAILS_ENV"] = ENV["RACK_ENV"] = env
      env
    end

    def environment
      ENV["RAILS_ENV"]
    end

    def boot_grpc_server
      RailsGrpc::Boot.new.exec(environment)
    end

    def print_banner
      puts "\e[#{31}m"
      puts <<-EOS
          ÛÛÛÛÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛÛÛÛÛ    ÛÛÛÛÛÛÛÛÛ
         °°ÛÛÛ°°°°°ÛÛÛ °°ÛÛÛ°°°°°ÛÛÛ  ÛÛÛ°°°°°ÛÛÛ
  ÛÛÛÛÛÛÛ °ÛÛÛ    °ÛÛÛ  °ÛÛÛ    °ÛÛÛ ÛÛÛ     °°°
 ÛÛÛ°°ÛÛÛ °ÛÛÛÛÛÛÛÛÛÛ   °ÛÛÛÛÛÛÛÛÛÛ °ÛÛÛ
°ÛÛÛ °ÛÛÛ °ÛÛÛ°°°°°ÛÛÛ  °ÛÛÛ°°°°°°  °ÛÛÛ
°ÛÛÛ °ÛÛÛ °ÛÛÛ    °ÛÛÛ  °ÛÛÛ        °°ÛÛÛ     ÛÛÛ
°°ÛÛÛÛÛÛÛ ÛÛÛÛÛ   ÛÛÛÛÛ ÛÛÛÛÛ        °°ÛÛÛÛÛÛÛÛÛ
 °°°°°ÛÛÛ°°°°°   °°°°° °°°°°          °°°°°°°°°
 ÛÛÛ °ÛÛÛ
°°ÛÛÛÛÛÛ
 °°°°°°
EOS
      puts "\e[0m"
    end

    def set_master_trap
      Signal.trap(:USR1) do
        t = Thread.new do
          @mutex.synchronize do
            launch_new_worker
          end
        end
        t.report_on_exception = false
        t.run
      end
    end

    def launch_new_worker
      new_worker_pid = Process.fork
      if new_worker_pid
        puts "Launch new worker process (pid: #{new_worker_pid}) and kill old worker (pid:#{@worker_pid})"
        retry_limit = WORKER_LAUNCH_RETRY_LIMIT

        # FIXME: ugly code
        while !process_exists?(new_worker_pid)
          puts "waiting new worker"
          sleep 1

          retry_limit -= 1
          if retry_limit < 0
            puts "Failed to Launch new worker..."
            exit 1
          end
        end
        sleep RAILS_LAUNCH_WAIT_TIME # FIXME: bad code

        Process.kill("TERM", @worker_pid)
        @worker_pid = new_worker_pid
      else
        boot_grpc_server
      end
    end

    def process_exists?(pid)
      Process.kill(0, pid.to_i)
      true
    rescue Error::SCRCH # no such process
      false
    rescue Error::EPERM # process exists, no permission
      true
    end
  end
end
