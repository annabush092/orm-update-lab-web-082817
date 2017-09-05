require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def persisted
    #returns true if instance is already in the database (thus has an id)
    !!self.id
  end

  def save
    #if the tweet instance is already in the db, update it
    if persisted == true
      self.update
    #if no corresponding row exists in the db, create a new instance
    else
      #put instance data into table
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      #get id from table and assign to instance
      sql = <<-SQL
        SELECT students.id
        FROM students
        ORDER BY id DESC
        LIMIT 1
      SQL
      @id = (DB[:conn].execute(sql))[0][0]
    end
    #return the saved instance
    self
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row_array)
    # create a new Student object given a row from the database
    Student.new(row_array[1], row_array[2], row_array[0])
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE students.name = ?
    SQL
    Student.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def update
    #update the record corresponding to this instance
    sql_update = <<-SQL
      UPDATE students
      SET name = ?,  grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql_update, self.name, self.grade, self.id)
    self
  end

end
