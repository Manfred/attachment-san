module AttachmentSan
  module ModuleExt
    ##
    #
    # a Module/Class for the given +name+. It differentiates from +const_get+
    # in that it _only_ searches in the namespace that it’s called on.
    #
    # ==== Parameters
    #
    # [+name+]
    #   The name of the Module/Class to lookup.
    #
    # ==== Examples
    #
    #   class A
    #     class B
    #     end
    #   end
    #
    #   class C; end
    #
    # If the requested mod exists in the namespace, the result is the same:
    #
    #   A.const_get('B') # => A::B
    #   A.modulized_mod_get('B') # => A::B
    #
    # Now notice that const_get finds the mod outside the `A' namespace:
    #
    #   A.const_get('C') # => C
    #   A.modulized_mod_get('C') # => NameError
    def modulized_mod_get(name)
      const = const_get(name)
      modulized_name = "#{self.name}::#{name}"
      
      if const.is_a?(Module) && const.name == modulized_name
        const
      else
        raise NameError, "uninitialized mod constant #{modulized_name}"
      end
    end
  end
  Module.send(:include, ModuleExt)
end