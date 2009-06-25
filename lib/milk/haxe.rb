module Milk
  class Haxe
    HAXE_HEADER_REGEX = /^\/\/ COMPILE_FLAGS (.*)$/
    HAXE_BIN = Milk::BIN_DIR+"/haxe"
    ENV['HAXE_LIBRARY_PATH'] = File.absolute_path(Milk::BIN_DIR+"/../haxe/std")
    HAXE_DIR = Milk::COMPONENTS_DIR + "/haxe"

    def initialize(page_name)
      @page_name = page_name
      base_path = HAXE_DIR + "/" + @page_name
      @haxe = base_path + ".hx"
      @haxe_swf = @haxe + ".swf"
      @swfmill = base_path + ".xml"
      @swfmill_swf = @swfmill + ".swf"

      raise PageNotFoundError if not File.file? @haxe

      # Compile swfmill resource if it exists and the binary is nonexistant/outdated
      if File.file? @swfmill
        if (not (File.file?(@swfmill_swf)) or (File.mtime(@swfmill) > File.mtime(@swfmill_swf)))
          compile_swfmill
        end
      end

      # Compile haxe binary if nonexistant/outdated 
      # if a swfmill resource exists, it can outdate the main swf too
      if (not (File.file?(@haxe_swf)) \
        or (File.mtime(@haxe) > File.mtime(@haxe_swf)) \
        or (File.file?(@swfmill_swf) \
          and File.mtime(@swfmill_swf) > File.mtime(@haxe_swf) \
        ) \
      )
        compile_haxe
      end
    end

    def render(mode='view')
      open(@haxe_swf)
    end
    
    private

    def popen3(*cmd)
      pw = IO::pipe   # pipe[0] for read, pipe[1] for write
      pr = IO::pipe
      pe = IO::pipe

      pid = fork{
        # child
        fork{
          # grandchild
          pw[1].close
          STDIN.reopen(pw[0])
          pw[0].close

          pr[0].close
          STDOUT.reopen(pr[1])
          pr[1].close

          pe[0].close
          STDERR.reopen(pe[1])
          pe[1].close

          exec(*cmd)
        }
        exit!(0)
      }

      pw[0].close
      pr[1].close
      pe[1].close
      Process.waitpid(pid)
      pi = [pw[1], pr[0], pe[0]]
      pw[1].sync = true
      if defined? yield
        begin
          return yield(*pi)
        ensure
          pi.each{|p| p.close unless p.closed?}
        end
      end
      pi
    end
    
    def run_command(*command)
      popen3(*command) do |stdin, stdout, stderr|
        stdin.close
        error = stderr.read
        if error.length > 0
          raise ExternalCompilerError.new(error.inspect)
        end
      end
    end
    
    def compile_swfmill
      command = ["swfmill", "simple", @swfmill, @swfmill_swf]
      Dir.chdir(Milk::HAXE_DIR)  
      run_command *command
    end
    
    def compile_haxe
      command = [HAXE_BIN,
        "-swf-version", "9", "--flash-strict",
        "-swf", @haxe_swf,
        "-main", @page_name,
        "-cp", Milk::HAXE_DIR]
      open @haxe, "r" do |file|
        line = file.readline
        if HAXE_HEADER_REGEX =~ line
          HAXE_HEADER_REGEX.match(line)[1].split(' ').each do |item|
            command.push(item)
          end
        end
      end
      if File.file? @swfmill_swf
        # For some reason, haxe doesn't like a full path here, so convert
        # to relative.
        command.push('-swf-lib')
        command.push(@swfmill_swf.split("/").last)
      end
      run_command *command
    end
    
  end

  # An exception raised by haxe or swfmill.
  class ExternalCompilerError < StandardError
  end

end


                






