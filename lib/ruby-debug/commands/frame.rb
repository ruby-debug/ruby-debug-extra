module Debugger
  module FrameFunctions # :nodoc:
    def adjust_frame(frame_pos, absolute)
      if absolute
        if frame_pos < 0
          abs_frame_pos = @state.frames.size + frame_pos
        else
          abs_frame_pos = frame_pos
        end
      else
        abs_frame_pos = @state.frame_pos + frame_pos
      end

      if abs_frame_pos >= @state.frames.size then
        print_error "Adjusting would put us beyond the oldest (initial) frame.\n"
        return
      elsif abs_frame_pos < 0 then
        print_error "Adjusting would put us beyond the newest (innermost) frame.\n"
        return
      end
      if @state.frame_pos != abs_frame_pos then
        @state.previous_line = nil
        @state.frame_pos = abs_frame_pos
      end
      frame = @state.frames[-1-@state.frame_pos]
      @state.binding, @state.file, @state.line = frame.binding, frame.file, frame.line
      print_current_frame(frame, @state.frame_pos)
    end

    def get_int(str, cmd)
      begin
        return Integer(@match[1])
      rescue
        print_error "%s argument needs to be a number.\n" % cmd
        return nil
      end
    end

  end

  class WhereCommand < Command # :nodoc:
    def regexp
      /^\s*(?:w(?:here)?|bt|backtrace)$/
    end

    def execute
      print_frames(@state.frames, @state.frame_pos)
    end

    class << self
      def help_command
        %w|where frame|
      end

      def help(cmd)
        if cmd == 'where'
          %{
            w[here]\tdisplay frames
          }
        else
          %{
            bt|backtrace\t\talias for where
          }
        end
      end
    end
  end

  class UpCommand < Command # :nodoc:
    def regexp
      /^\s* u(?:p)? (?:\s+(.*))? .*$/x
    end

    def execute
      unless @match[1]
        pos = 1
      else
        pos = get_int(@match[1], "Up")
        return unless pos
      end
      adjust_frame(pos, false)
    end

    class << self
      def help_command
        up
      end

      def help(cmd)
        %{
          up[count]\tmove to higher frame
        }
      end
    end
  end

  class DownCommand < Command # :nodoc:
    def regexp
      /^\s* d(?:own)? (?:\s+(.*))? .*$/x
    end

    def execute
      if not @match[1]
        pos = 1
      else
        pos = get_int(@match[1], "Down")
        return unless pos
      end
      adjust_frame(-pos, false)
    end

    class << self
      def help_command
        'down'
      end

      def help(cmd)
        %{
          down[count]\tmove to lower frame
        }
      end
    end
  end
  
  class FrameCommand < Command # :nodoc:
    include FrameFunctions
    def regexp
      /^\s* f(?:rame)? (?:\s+ (.*))? \s*$/x
    end

    def execute
      if not @match[1]
        print "Missing a frame number argument.\n"
        return
      else
        pos = get_int(@match[1], "Frame")
        return unless pos
      end
      adjust_frame(pos < 0 ? pos : pos-1, true)
    end

    class << self
      def help_command
        'frame'
      end

      def help(cmd)
        %{
          f[rame] frame-number
          Move the current frame to the specified frame number.

          A negative number indicates position from the other end.  So
          'frame -1' moves to the oldest frame, and 'frame 0' moves to
          the newest frame.
        }
      end
    end
  end
end