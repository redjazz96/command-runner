module Command
  class Runner
    module Backends

      # Spawns a process using ruby's Process.spawn.
      class Spawn < Fake

        # Returns whether or not this backend is available on this
        # platform.  Process.spawn doesn't work the way we want it to
        # on JRuby 1.9 mode, so we prevent this from being used on
        # that platform.
        #
        # @return [Boolean]
        def self.available?(_ = false)
          Process.respond_to?(:spawn) && !(RUBY_PLATFORM == "java" && RUBY_VERSION =~ /\A1\.9/)
        end

        # Initialize the backend.
        def initialize
          super
        end

        # Run the given command and arguments, in the given environment.
        #
        # @note The block is called in another thread, so in ruby
        #   versions other than MRI, make sure your code is
        #   thread-safe.
        # @raise [Errno::ENOENT] if the command doesn't exist.
        # @yield (see Fake#call)
        # @param (see Fake#call)
        # @return (see Fake#call)
        def call(command, arguments, env = {}, options = {}, &block)
          super
          stderr_r, stderr_w = IO.pipe
          stdout_r, stdout_w = IO.pipe
          stdin_r,  stdin_w  = IO.pipe

          if options[:input]
            stdin_w.write(options.delete(:input))
          end
          new_options = options.merge(:in => stdin_r,
            :out => stdout_w, :err => stderr_w)

          stdin_w.close

          line = [command, *arguments].join(' ')

          start_time = Time.now
          process_id = spawn(env, command, arguments, new_options)

          future do
            _, status = wait2(process_id)
            end_time = Time.now

            [stdout_w, stderr_w].each(&:close)

            message = Message.new :process_id => process_id,
                        :exit_code  => status.exitstatus,
                        :finished   => true,
                        :time       => (start_time - end_time).abs,
                        :env        => env,
                        :options    => options,
                        :stdout     => stdout_r.read,
                        :stderr     => stderr_r.read,
                        :line       => line,
                        :executed   => true,
                        :status     => status

            if block_given?
              block.call(message)
            else
              message
            end
          end
        end

        # Spawn the given process, in the environment with the
        # given options.
        #
        # @see Process.spawn
        # @return [Numeric] the process id
        def spawn(env, command, arguments, options)
          if options.delete(:unsafe)
            Process.spawn(env, "#{command} #{arguments.join(' ')}", options)
          else
            Process.spawn(env, command, *arguments, options)
          end
        end

        # Waits for the given process, and returns the process id and the
        # status.
        #
        # @see Process.wait2
        # @return [Array<(Numeric, Process::Status)>]
        def wait2(process_id = -1)
          Process.wait2(process_id)
        end

      end

    end
  end
end
