require 'test_helper'
require 'schema'

class Project < ActiveRecord::Base
  has_many :tasks
end

class Task < ActiveRecord::Base
  belongs_to :project
  
  named_scope :completed, :conditions => 'completed_at IS NOT NULL'
  
  def completed?
    !completed_at.nil?
  end
  
  def project_name
    project.name
  end
end

class TableDisplayTest < ActiveSupport::TestCase
  fixtures :all
  
  def setup
    @project = projects(:this_project)
  end
  
  test "#to_table is available on arrays" do
    assert_nothing_raised do
      [].to_table
    end
  end
  
  test "#to_table is available on ActiveRecord find results" do # which should be arrays, in fact
    assert_nothing_raised do
      Task.find(:all).to_table
    end
  end
  
  test "#to_table is available on ActiveRecord named_scopes" do
    assert_nothing_raised do
      Task.completed.to_table
    end      
  end
  
  test "#to_table is available on ActiveRecord association collections" do
    assert_nothing_raised do
      @project.tasks.to_table
    end      
  end
  
  test "#to_table is available on named scopes in ActiveRecord association collections" do
    assert_nothing_raised do
      @project.tasks.completed.to_table
    end      
  end
  
  # we run some simple regression tests to check that everything works as expected
  
  test "#to_table by default includes all the database columns in database order" do
    assert_equal <<END.strip, @project.tasks.to_table.join("\n")
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
| id | project_id | description            | due_on           | completed_at                   | created_at                     | updated_at                     |
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | Tue Mar 24 23:17:05 +1300 2009 | Mon Mar 23 09:11:02 +1300 2009 | Tue Mar 24 23:17:05 +1300 2009 |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                            | Mon Mar 23 09:11:46 +1300 2009 | Mon Mar 23 09:11:46 +1300 2009 |
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
END
  end
  
  test "#to_table by default includes all the database columns in database order even when not called on a typeless array" do
    assert_equal <<END.strip, @project.tasks.find(:all).to_table.join("\n")
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
| id | project_id | description            | due_on           | completed_at                   | created_at                     | updated_at                     |
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | Tue Mar 24 23:17:05 +1300 2009 | Mon Mar 23 09:11:02 +1300 2009 | Tue Mar 24 23:17:05 +1300 2009 |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                            | Mon Mar 23 09:11:46 +1300 2009 | Mon Mar 23 09:11:46 +1300 2009 |
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+
END
  end
  
  test "#to_table leaves out any attributes not loaded" do
    assert_equal <<END.strip, @project.tasks.find(:all, :select => "id, project_id, completed_at").to_table.join("\n")
+----+------------+--------------------------------+
| id | project_id | completed_at                   |
+----+------------+--------------------------------+
|  1 |         31 | Tue Mar 24 23:17:05 +1300 2009 |
|  2 |         31 | nil                            |
+----+------------+--------------------------------+
END
  end

  test "#to_table also shows any attributes that are not columns on the underlying table" do
    assert_equal <<END.strip, @project.tasks.find(:all, :joins => :project, :select => "tasks.id, project_id, projects.description AS BigProjectDescription").to_table.join("\n")
+----+------------+-----------------------------------------------------------------------------------------------------+
| id | project_id | BigProjectDescription                                                                               |
+----+------------+-----------------------------------------------------------------------------------------------------+
|  1 |         31 | "A handy plugin for displaying sets of records in a table format, for easy reading at the console." |
|  2 |         31 | "A handy plugin for displaying sets of records in a table format, for easy reading at the console." |
+----+------------+-----------------------------------------------------------------------------------------------------+
END
  end
  
  test "#to_table excludes any columns named in :except" do
    assert_equal <<END.strip, @project.tasks.to_table(:except => ['created_at', :completed_at]).join("\n")
+----+------------+------------------------+------------------+--------------------------------+
| id | project_id | description            | due_on           | updated_at                     |
+----+------------+------------------------+------------------+--------------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | Tue Mar 24 23:17:05 +1300 2009 |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | Mon Mar 23 09:11:46 +1300 2009 |
+----+------------+------------------------+------------------+--------------------------------+
END
  end
  
  test "#to_table excludes all columns except those named in :only" do
    assert_equal <<END.strip, @project.tasks.to_table(:only => ['id', :due_on]).join("\n")
+----+------------------+
| id | due_on           |
+----+------------------+
|  1 | Wed, 25 Mar 2009 |
|  2 | Sun, 05 Apr 2009 |
+----+------------------+
END
  end
  
  test "#to_table also shows any :methods given as columns" do
    assert_equal <<END.strip, @project.tasks.to_table(:methods => [:completed?, 'project_name']).join("\n")
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+------------+------------------------+
| id | project_id | description            | due_on           | completed_at                   | created_at                     | updated_at                     | completed? | project_name           |
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+------------+------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | Tue Mar 24 23:17:05 +1300 2009 | Mon Mar 23 09:11:02 +1300 2009 | Tue Mar 24 23:17:05 +1300 2009 | true       | "table_display plugin" |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                            | Mon Mar 23 09:11:46 +1300 2009 | Mon Mar 23 09:11:46 +1300 2009 | false      | "table_display plugin" |
+----+------------+------------------------+------------------+--------------------------------+--------------------------------+--------------------------------+------------+------------------------+
END
  end
  
  test "#to_table shows the #to_s format rather than the #inspect format when :inspect => false is set" do
    assert_equal <<END.strip, @project.tasks.to_table(:inspect => false).join("\n")
+----+------------+----------------------+------------+--------------------------------+--------------------------------+--------------------------------+
| id | project_id | description          | due_on     | completed_at                   | created_at                     | updated_at                     |
+----+------------+----------------------+------------+--------------------------------+--------------------------------+--------------------------------+
|  1 |         31 | Write a handy plugin | 2009-03-25 | Tue Mar 24 23:17:05 +1300 2009 | Mon Mar 23 09:11:02 +1300 2009 | Tue Mar 24 23:17:05 +1300 2009 |
|  2 |         31 | Blog the plugin      | 2009-04-05 |                                | Mon Mar 23 09:11:46 +1300 2009 | Mon Mar 23 09:11:46 +1300 2009 |
+----+------------+----------------------+------------+--------------------------------+--------------------------------+--------------------------------+
END
    # note the strings no longer have quotes, the nil is not shown, and the date format happens to be different
  end

  test "#to_table on an empty array returns an empty result" do
    assert_equal [], [].to_table
  end
end
