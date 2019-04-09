require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize (dog)
  # binding.pry
    #The `#initialize` method accepts a hash or keyword argument value with key-value pairs as
    #an argument. key-value pairs need to contain id, name, and breed.
    @name = dog[:name]
    @breed = dog[:breed]
    @id = dog[:id]
  end

  def self.create_table
    #creates the dogs table in the database
    DB[:conn].execute('CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)')
  end

  def self.drop_table
    #drops the dogs table from the database
    DB[:conn].execute('DROP TABLE dogs')
  end

  def save
    # returns an instance of the dog class
    # saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?,?)',self.name, self.breed)
    self.id = DB[:conn].execute('SELECT id FROM dogs WHERE name = ? AND breed = ?',self.name, self.breed).flatten[0]
    self
  end

  def self.create(hash)
    #takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save
    #method to save that dog to the database
    #returns a new dog object
    DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?,?)',hash[:name], hash[:breed])
    new_dog = Dog.new(hash)
    new_dog.id = DB[:conn].execute('SELECT id FROM dogs WHERE name = ? AND breed = ?',hash[:name], hash[:breed]).flatten[0]
    new_dog
  end

  def self.find_by_id(id)
    #returns a new dog object by id
    a = DB[:conn].execute('SELECT * FROM dogs WHERE id = (?)',id).flatten
    hash = {id: a[0], name: a[1], breed: a[2]}
    Dog.new(hash)

  end

  def self.find_or_create_by(dog)
    #creates an instance of a dog if it does not already exist
    #when two dogs have the same name and different breed, it returns the correct dog
    #when creating a new dog with the same name as persisted dogs, it returns the correct dog
    if dog[:id] == nil
       new_dog = Dog.create(dog)
    else
      Dog.find_by_id(dog[:id])
    end
  end

  def self.new_from_db(new_dog)
    #creates an instance with corresponding attribute values
    Dog.new({id: new_dog[0], name: new_dog[1], breed: new_dog[2]})
  end

  def self.find_by_name(name)
    #returns an instance of student that matches the name from the DB
    Dog.find_by_id(DB[:conn].execute('SELECT * FROM dogs WHERE name = (?)',name).flatten[0])
  end

  def update
    #updates the record associated with a given instance
    DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?',self.name, self.breed, self.id)
  end

end
