require 'table_display'

# Rails 2.3 named_scopes certainly quack like enumerables, but surprisingly they don't themself include Enumerable.
if ActiveRecord.const_defined?(:NamedScope) && ActiveRecord::NamedScope.const_defined?(:Scope)
  ActiveRecord::NamedScope::Scope.send(:include, TableDisplay)
end
