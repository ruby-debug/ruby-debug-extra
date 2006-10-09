module Debugger
  module VarFunctions # :nodoc:
    def var_list(ary, bind = nil)
      bind ||= @state.binding
      ary.sort!
      for v in ary
        print "  %s => %s\n", v, eval(v, bind).inspect
      end
    end
  end

  class VarConstantCommand < Command # :nodoc:
    include VarFunctions

    def regexp
      /^\s*v(?:ar)?\s+c(?:onst(?:ant)?)?\s+/
    end

    def execute
      obj = debug_eval(@match.post_match)
      unless obj.kind_of? Module
        print "Should be Class/Module: %s\n", @match.post_match
      else
        var_list(obj.constants, obj.module_eval{binding()})
      end
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] c[onst] <object>\t\tshow constants of object
        }
      end
    end
  end

  class VarGlobalCommand < Command # :nodoc:
    include VarFunctions

    def regexp
      /^\s*v(?:ar)?\s+g(?:lobal)?\s*$/
    end

    def execute
      var_list(global_variables)
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] g[lobal]\t\t\tshow global variables
        }
      end
    end
  end

  class VarInstanceCommand < Command # :nodoc:
    include VarFunctions

    def regexp
      /^\s*v(?:ar)?\s+i(?:nstance)?\s+/
    end

    def execute
      obj = debug_eval(@match.post_match)
      var_list(obj.instance_variables, obj.instance_eval{binding()})
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] i[nstance] <object>\tshow instance variables of object
        }
      end
    end
  end

  class VarLocalCommand < Command # :nodoc:
    include VarFunctions

    def regexp
      /^\s*v(?:ar)?\s+l(?:ocal)?\s*$/
    end

    def execute
      var_list(eval("local_variables", @state.binding))
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] l[ocal]\t\t\tshow local variables
        }
      end
    end
  end
end