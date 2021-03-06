require "pry"

class Dog
    
    attr_accessor :name, :breed, :id

    def initialize(name:,breed:,id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def save
        if self.id
            self.update
        else
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL
        DB[:conn].execute(sql,self.name, self.breed)
        @id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
        return self
        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ? , breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql,self.name,self.breed,self.id)
        return self
    end

    def self.create(name:,breed:)
        new_dog = Dog.new(name: name,breed: breed)
        new_dog.save
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * from dogs WHERE id = ?;
            SQL
        self.new_from_db(DB[:conn].execute(sql,id).first)
    end

    def self.new_from_db(row)
        # rows.collect do |row|
            Dog.new(id: row[0], name: row[1], breed: row[2])
        # end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?;
            SQL
        rows = DB[:conn].execute(sql,name)
        result=rows.collect{|row| self.new_from_db(row)}
        if result.length == 1
            return result.first
        else
            return result
        end
    end

    def self.find_or_create_by(name:, breed:)
        result = self.find_by_name(name)
        if  !result
             self.create(name: name, breed: breed)
        elsif result.class == Array
            if result.select {|dog| dog.breed == breed}.length != 0
                result.select {|dog| dog.breed == breed}.first
            else
                self.create(name: name, breed: breed)
            end
        else
            return result
        end
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                    name TEXT,
                    breed TEXT
            );
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql)
    end




end