class Dog
    attr_accessor :name, :breed, :id
    
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
       
      if self.id == nil 
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)",[self.name, self.breed])
            self.id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ? ORDER BY id DESC LIMIT 1",[name, breed])[0][0]
       else  
            DB[:conn].execute("UPDATE dogs name = ?, breed = ? WHERE id = ?",[self.name, self.breed, self.id])
       end
       self 
    end

    def self.create(name:, breed:)
        self.new(name: name, breed: breed).save
    end

    def self.find_by_id(id)
       results = DB[:conn].execute("SELECT dogs.name,dogs.breed FROM dogs WHERE id = ?",[id])
       self.new(name:results[0][0], breed:results[0][1],id:id)
    end

    def self.find_or_create_by(name:, breed:)
        results = DB[:conn].execute("SELECT dogs.name, dogs.breed, dogs.id FROM dogs WHERE name = ? AND breed = ?", [name, breed])
        if results.length == 0
            self.create(name:name, breed:breed)
        else
            self.new(name: results[0][0], breed: results[0][1], id: results[0][2])
        end

    end

    def self.new_from_db(array)
        #This is an interesting method. Ultimately, the database is going to return an array representing a dog's data.
        # We need a way to cast that data into the appropriate attributes of a dog. This method encapsulates that functionality.
        # You can even think of it as new_from_array. Methods like this, that return instances of the class, are known as constructors, 
        #just like .new, except that they extend the functionality of .new without overwriting initialize.
        
        
        #self.create(name:array[1], breed:array[2])

        self.new(name:array[1],breed:array[2],id:array[0])

    end

    def self.find_by_name(name)
#This spec will first insert a dog into the database and then attempt to find it by calling the find_by_name method. The expectations
 #are that an instance of the dog class that has all the properties of a dog is returned, not primitive data.
#Internally, what will the find_by_name method do to find a dog; which SQL statement must it run? Additionally, what method might
  #   find_by_name use internally to quickly take a row and create an instance to represent that data?
        results = DB[:conn].execute("SELECT dogs.name,dogs.breed,dogs.id FROM dogs WHERE name = ?",[name])
        self.new(name:name, breed:results[0][1],id:results[0][2])


    end

    def update
        results = DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", [name, breed, id])
    end
end
