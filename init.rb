require 'table_display'

# all Enumerable classes should get TableDisplay functionality...
Enumerable.send(:include, TableDisplay)

# including those that have already included Enumerable by the time this plugin is loaded.
# Ruby doesn't recursively update through the module tree, so although any new classes/modules
# that include Enumerable will get TableDisplay, we have to do it ourself for older ones.
ObjectSpace.each_object(Module) {|o| o.send(:include, TableDisplay) if o.ancestors.include?(Enumerable)}
ObjectSpace.each_object(Class)  {|o| o.send(:include, TableDisplay) if o.ancestors.include?(Enumerable)}

# Rails 2.3 named_scopes certainly quack like enumerables, but surprisingly they don't themself include Enumerable.
if ActiveRecord.const_defined?(:NamedScope) && ActiveRecord::NamedScope.const_defined?(:Scope)
  ActiveRecord::NamedScope::Scope.send(:include, TableDisplay)
end
