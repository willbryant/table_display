# coding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), 'schema'))
require 'ostruct'

class Time
  def to_s(*args)
    return to_formatted_s(*args) unless args.empty?
    strftime("%Y-%m-%d %H:%M:%S %z")
  end
  
  def inspect
    to_s
  end
end

class Project < ActiveRecord::Base
  has_many :tasks
end

class Task < ActiveRecord::Base
  belongs_to :project
  
  scope :completed, -> { where('completed_at IS NOT NULL') }
  
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
  
  test "#to_table_display is available on arrays" do
    assert_nothing_raised do
      [].to_table_display
    end
  end
  
  test "#to_table_display is available on ActiveRecord find results" do # which should be arrays, in fact
    assert_nothing_raised do
      Task.all.to_table_display
    end
  end
  
  test "#to_table_display is available on ActiveRecord named_scopes" do
    assert_nothing_raised do
      Task.completed.to_table_display
    end      
  end
  
  test "#to_table_display is available on ActiveRecord association collections" do
    assert_nothing_raised do
      @project.tasks.to_table_display
    end      
  end
  
  test "#to_table_display is available on named scopes in ActiveRecord association collections" do
    assert_nothing_raised do
      @project.tasks.completed.to_table_display
    end      
  end
  
  # we run some simple regression tests to check that everything works as expected
  
  test "#to_table_display by default includes all the database columns in database order" do
    assert_equal <<END.strip, @project.tasks.to_table_display.join("\n")
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+
| id | project_id | description            | due_on           | completed_at              | created_at                | updated_at                |
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | 2009-03-24 23:17:05 +1300 | 2009-03-23 09:11:02 +1300 | 2009-03-24 23:17:05 +1300 |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                       | 2009-03-23 09:11:46 +1300 | 2009-03-23 09:11:46 +1300 |
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+
END
  end
  
  test "#to_table_display by default includes all the database columns in database order even when not called on a typeless array" do
    assert_equal <<END.strip, @project.tasks.all.to_table_display.join("\n")
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+
| id | project_id | description            | due_on           | completed_at              | created_at                | updated_at                |
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | 2009-03-24 23:17:05 +1300 | 2009-03-23 09:11:02 +1300 | 2009-03-24 23:17:05 +1300 |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                       | 2009-03-23 09:11:46 +1300 | 2009-03-23 09:11:46 +1300 |
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+
END
  end
  
  test "#to_table_display leaves out any attributes not loaded" do
    assert_equal <<END.strip, @project.tasks.select("id, project_id, completed_at").to_table_display.join("\n")
+----+------------+---------------------------+
| id | project_id | completed_at              |
+----+------------+---------------------------+
|  1 |         31 | 2009-03-24 23:17:05 +1300 |
|  2 |         31 | nil                       |
+----+------------+---------------------------+
END
  end

  test "#to_table_display also shows any attributes that are not columns on the underlying table" do
    assert_equal <<END.strip, @project.tasks.joins(:project).select("tasks.id, project_id, projects.description AS BigProjectDescription").to_table_display.join("\n")
+----+------------+-----------------------------------------------------------------------------------------------------+
| id | project_id | BigProjectDescription                                                                               |
+----+------------+-----------------------------------------------------------------------------------------------------+
|  1 |         31 | "A handy plugin for displaying sets of records in a table format, for easy reading at the console." |
|  2 |         31 | "A handy plugin for displaying sets of records in a table format, for easy reading at the console." |
+----+------------+-----------------------------------------------------------------------------------------------------+
END
  end
  
  test "#to_table_display excludes any columns named in :except" do
    assert_equal <<END.strip, @project.tasks.to_table_display(:except => ['created_at', :completed_at]).join("\n")
+----+------------+------------------------+------------------+---------------------------+
| id | project_id | description            | due_on           | updated_at                |
+----+------------+------------------------+------------------+---------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | 2009-03-24 23:17:05 +1300 |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | 2009-03-23 09:11:46 +1300 |
+----+------------+------------------------+------------------+---------------------------+
END
  end
  
  test "#to_table_display excludes all columns except those named in :only" do
    assert_equal <<END.strip, @project.tasks.to_table_display(:only => ['id', :due_on]).join("\n")
+----+------------------+
| id | due_on           |
+----+------------------+
|  1 | Wed, 25 Mar 2009 |
|  2 | Sun, 05 Apr 2009 |
+----+------------------+
END
  end
  
  test "#to_table_display keeps the columns in the order given in :only" do
    assert_equal <<END.strip, @project.tasks.to_table_display(:only => [:due_on, 'id']).join("\n")
+------------------+----+
| due_on           | id |
+------------------+----+
| Wed, 25 Mar 2009 |  1 |
| Sun, 05 Apr 2009 |  2 |
+------------------+----+
END
    assert_equal <<END.strip, @project.tasks.to_table_display(:only => [:due_on, :id]).join("\n")
+------------------+----+
| due_on           | id |
+------------------+----+
| Wed, 25 Mar 2009 |  1 |
| Sun, 05 Apr 2009 |  2 |
+------------------+----+
END
  end
  
  test "#to_table_display accepts an unnamed list of arguments for column names" do
    assert_equal <<END.strip, @project.tasks.to_table_display('id', :due_on, :completed?).join("\n")
+----+------------------+------------+
| id | due_on           | completed? |
+----+------------------+------------+
|  1 | Wed, 25 Mar 2009 | true       |
|  2 | Sun, 05 Apr 2009 | false      |
+----+------------------+------------+
END
  end
  
  test "#to_table_display allows auxiliary named arguments with the array format" do
    assert_equal <<END.strip, @project.tasks.to_table_display('id', :due_on, :completed?, :inspect => false).join("\n")
+----+------------+------------+
| id | due_on     | completed? |
+----+------------+------------+
|  1 | 2009-03-25 | true       |
|  2 | 2009-04-05 | false      |
+----+------------+------------+
END
  end
  
  test "#to_table_display also shows any :methods given as columns" do
    assert_equal <<END.strip, @project.tasks.to_table_display(:methods => [:completed?, 'project_name']).join("\n")
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+------------+------------------------+
| id | project_id | description            | due_on           | completed_at              | created_at                | updated_at                | completed? | project_name           |
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+------------+------------------------+
|  1 |         31 | "Write a handy plugin" | Wed, 25 Mar 2009 | 2009-03-24 23:17:05 +1300 | 2009-03-23 09:11:02 +1300 | 2009-03-24 23:17:05 +1300 | true       | "table_display plugin" |
|  2 |         31 | "Blog the plugin"      | Sun, 05 Apr 2009 | nil                       | 2009-03-23 09:11:46 +1300 | 2009-03-23 09:11:46 +1300 | false      | "table_display plugin" |
+----+------------+------------------------+------------------+---------------------------+---------------------------+---------------------------+------------+------------------------+
END
  end
  
  test "#to_table_display shows the #to_s format rather than the #inspect format when :inspect => false is set" do
    assert_equal <<END.strip, @project.tasks.to_table_display(:inspect => false).join("\n")
+----+------------+----------------------+------------+---------------------------+---------------------------+---------------------------+
| id | project_id | description          | due_on     | completed_at              | created_at                | updated_at                |
+----+------------+----------------------+------------+---------------------------+---------------------------+---------------------------+
|  1 |         31 | Write a handy plugin | 2009-03-25 | 2009-03-24 23:17:05 +1300 | 2009-03-23 09:11:02 +1300 | 2009-03-24 23:17:05 +1300 |
|  2 |         31 | Blog the plugin      | 2009-04-05 |                           | 2009-03-23 09:11:46 +1300 | 2009-03-23 09:11:46 +1300 |
+----+------------+----------------------+------------+---------------------------+---------------------------+---------------------------+
END
    # note the strings no longer have quotes, the nil is not shown, and the date format happens to be different
  end
  
  test "#to_table_display correctly pads out to match the length in characters of long values with utf-8 sequences" do
    tasks(:write_a_handy_plugin).update_attribute(:description, "Write a handy plugin \342\200\223 with UTF-8 handling")
    assert_equal <<END.strip, @project.tasks.to_table_display(:only => [:id, :description], :inspect => false).join("\n")
+----+--------------------------------------------+
| id | description                                |
+----+--------------------------------------------+
|  1 | Write a handy plugin – with UTF-8 handling |
|  2 | Blog the plugin                            |
+----+--------------------------------------------+
END
  end

  test "#to_table_display correctly pads out short values with utf-8 sequences" do
    tasks(:blog_the_plugin).update_attribute(:description, "Blog \342\200\223 plugin")
    assert_equal <<END.strip, @project.tasks.to_table_display(:only => [:id, :description], :inspect => false).join("\n")
+----+----------------------+
| id | description          |
+----+----------------------+
|  1 | Write a handy plugin |
|  2 | Blog – plugin        |
+----+----------------------+
END
  end

  test "#to_table_display on an empty array returns an empty result" do
    assert_equal [], [].to_table_display
  end
  
  test "#to_table_display can extract data out of raw hashes" do
    @records = [{:foo => 1234, :bar => "test"},
                {:bar => "text", :baz => 5678}]
    results = @records.to_table_display.join("\n")
    assert results.include?('| foo  |')
    assert results.include?('| bar    |')
    assert results.include?('| baz  |')
    assert_equal <<END.strip, @records.to_table_display(:only => [:foo, :bar, :baz]).join("\n")
+------+--------+------+
| foo  | bar    | baz  |
+------+--------+------+
| 1234 | "test" | nil  |
| nil  | "text" | 5678 |
+------+--------+------+
END
    assert_equal <<END.strip, @records.to_table_display(:only => [:bar, :baz]).join("\n")
+--------+------+
| bar    | baz  |
+--------+------+
| "test" | nil  |
| "text" | 5678 |
+--------+------+
END
    assert_equal <<END.strip, @records.to_table_display(:except => [:bar]).join("\n")
+------+------+
| foo  | baz  |
+------+------+
| 1234 | nil  |
| nil  | 5678 |
+------+------+
END
  end
  
  test "#to_table_display can extract data out of OpenStruct records" do
    @records = [OpenStruct.new(:foo => 1234, :bar => "test"),
                OpenStruct.new(:bar => "text", :baz => 5678)]
    results = @records.to_table_display.join("\n")
    assert results.include?('| foo  |')
    assert results.include?('| bar    |')
    assert results.include?('| baz  |')
    assert_equal <<END.strip, @records.to_table_display(:only => [:foo, :bar, :baz]).join("\n")
+------+--------+------+
| foo  | bar    | baz  |
+------+--------+------+
| 1234 | "test" | nil  |
| nil  | "text" | 5678 |
+------+--------+------+
END
    assert_equal <<END.strip, @records.to_table_display(:only => [:bar, :baz]).join("\n")
+--------+------+
| bar    | baz  |
+--------+------+
| "test" | nil  |
| "text" | 5678 |
+--------+------+
END
    assert_equal <<END.strip, @records.to_table_display(:except => [:bar]).join("\n")
+------+------+
| foo  | baz  |
+------+------+
| 1234 | nil  |
| nil  | 5678 |
+------+------+
END
  end
end
