class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil,name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"
        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
        DB[:conn].execute(sql, self.name, self.breed)
        row = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0]
        self.id = row[0]
        self
    end

    def self.create(name:, breed:)
        d = Dog.new(name: name, breed: breed)
        d.save
    end

    def self.new_from_db(row)
        d = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?;"
        row = DB[:conn].execute(sql, id)[0]
        Dog.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
        row = DB[:conn].execute(sql, name, breed)[0]

        if row
            Dog.new_from_db(row)
        else
            Dog.create(name: name, breed: breed)
        end

    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
        row = DB[:conn].execute(sql, name)[0]
        Dog.new_from_db(row)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end