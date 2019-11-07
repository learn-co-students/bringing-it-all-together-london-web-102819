class Dog

    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table

        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name STRING,
                breed STRING
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id 
            self.update
        else 
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:) 
        dog = self.new(name: name, breed: breed)
        dog = dog.save 
        dog
    end

    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        self.new_from_db(result)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if dog.empty?
            new_dog = Dog.create(name: name, breed: breed) 
        else dog = dog[0]
            dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0])
        end
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        self.new_from_db(dog)
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end

end